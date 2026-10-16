package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/progress"
	"github.com/charmbracelet/bubbles/viewport"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/glamour"
	"github.com/charmbracelet/lipgloss"
	"github.com/creack/pty"
)

type screen int

const (
	screenList screen = iota
	screenDetail
)

// ---- list item ----

type exItem struct {
	ex     Exercise
	passed bool
}

func (i exItem) Title() string {
	if i.passed {
		return "✓ " + i.ex.Title
	}
	return i.ex.Title
}
func (i exItem) Description() string {
	badge := difficultyBadge(i.ex.Difficulty)
	if i.passed {
		return badge + "  ·  " + passStyle.Render("solved")
	}
	if i.ex.VerifyPath == "" {
		return badge + "  ·  no verify.sh"
	}
	return badge
}
func (i exItem) FilterValue() string { return i.ex.Title }

// ---- messages ----

type tickMsg time.Time

type confettiTickMsg time.Time

// watchTickMsg signals it is time to run a background verify for exercise idx.
type watchTickMsg struct{ idx int }

// watchResultMsg carries the outcome of a background (live) verify run.
type watchResultMsg struct {
	idx    int
	passed bool
	output []string
}

// streamMsg carries one line of live script output, or (done=true) the final
// result once the process exits.
type streamMsg struct {
	line   string
	done   bool
	result verifyDoneMsg
}

type verifyDoneMsg struct {
	passed   bool
	exitCode int
	err      error
}

type setupDoneMsg struct {
	output string
	err    error
}

// checkStatus is the state of a single verify.sh check.
type checkStatus uint8

const (
	checkPending checkStatus = iota
	checkPass
	checkFail
)

var (
	ansiRe  = regexp.MustCompile(`\x1b\[[0-9;]*m`)
	checkRe = regexp.MustCompile(`(?i)check\s+(\d+)\s*/\s*(\d+).*?:\s*\**\s*(pass|fail)`)
)

// ---- styles ----

var (
	titleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("230")).
			Background(lipgloss.Color("63")).
			Padding(0, 1)

	helpStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("241")).
			Padding(0, 1)

	paneStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(lipgloss.Color("63"))

	passStyle     = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("42"))
	failStyle     = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("196"))
	runStyle      = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("214"))
	timerStyle    = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("117"))
	watchStyle    = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("213"))
	consoleHeader = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("63"))
)

func difficultyBadge(d string) string {
	switch strings.ToLower(d) {
	case "easy":
		return lipgloss.NewStyle().Foreground(lipgloss.Color("42")).Render("● easy")
	case "medium":
		return lipgloss.NewStyle().Foreground(lipgloss.Color("214")).Render("● medium")
	case "hard":
		return lipgloss.NewStyle().Foreground(lipgloss.Color("196")).Render("● hard")
	default:
		return "● " + d
	}
}

// ---- model ----

type model struct {
	exercises []Exercise
	list      list.Model
	vp        viewport.Model
	progress  progress.Model
	renderer  *glamour.TermRenderer

	screen   screen
	current  int
	revealed int

	// live verify state
	running bool
	console []string
	stream  chan streamMsg

	// per-check progress parsed from streamed verify output
	checks     []checkStatus
	checkTotal int

	// cluster preflight
	clusterKnown     bool
	kubectlFound     bool
	clusterCtx       string
	clusterReachable bool

	lastResult *verifyDoneMsg
	setupMsg   string
	passed     map[string]bool

	// live verify (watch)
	watchIdx      int // index being watched, or -1
	watchResultOK bool
	watchHasRes   bool
	watchResIdx   int

	// celebration
	confetti confetti

	// timer
	timerRunning bool
	timerStart   time.Time
	timerAccum   time.Duration

	width, height int
	ready         bool
}

func newModel(exs []Exercise) model {
	m := model{
		exercises: exs,
		screen:    screenList,
		passed:    make(map[string]bool),
		progress:  progress.New(progress.WithDefaultGradient()),
		watchIdx:  -1,
		confetti:  newConfetti(),
	}

	delegate := list.NewDefaultDelegate()
	l := list.New(nil, delegate, 0, 0)
	l.Title = "CKAD Exercises"
	l.Styles.Title = titleStyle
	l.SetShowStatusBar(true)
	l.SetFilteringEnabled(true)
	m.list = l
	m.rebuildList()

	// Global session timer starts running at launch.
	m.timerRunning = true
	m.timerStart = time.Now()
	return m
}

func (m *model) rebuildList() {
	items := make([]list.Item, len(m.exercises))
	for i, e := range m.exercises {
		items[i] = exItem{ex: e, passed: m.passed[e.DirName]}
	}
	m.list.SetItems(items)
}

// parseCheck inspects a streamed verify line like "Check 3/5 - ...: PASS" and
// updates the per-check progress state.
func (m *model) parseCheck(line string) {
	clean := ansiRe.ReplaceAllString(line, "")
	mt := checkRe.FindStringSubmatch(clean)
	if mt == nil {
		return
	}
	cur, _ := strconv.Atoi(mt[1])
	total, _ := strconv.Atoi(mt[2])
	if total > m.checkTotal {
		m.checkTotal = total
	}
	for len(m.checks) < total {
		m.checks = append(m.checks, checkPending)
	}
	if cur >= 1 && cur <= len(m.checks) {
		if strings.EqualFold(mt[3], "pass") {
			m.checks[cur-1] = checkPass
		} else {
			m.checks[cur-1] = checkFail
		}
	}
}

func (m *model) resetChecks() {
	m.checks = nil
	m.checkTotal = 0
}

// checksView renders the per-check progress indicator, e.g. "■■□□□ 2/5 checks".
func (m model) checksView() string {
	if m.checkTotal == 0 {
		return ""
	}
	var sb strings.Builder
	passed := 0
	for i := 0; i < m.checkTotal; i++ {
		st := checkPending
		if i < len(m.checks) {
			st = m.checks[i]
		}
		switch st {
		case checkPass:
			sb.WriteString(passStyle.Render("■"))
			passed++
		case checkFail:
			sb.WriteString(failStyle.Render("■"))
		default:
			sb.WriteString(helpStyle.Render("□"))
		}
	}
	return sb.String() + " " + helpStyle.Render(fmt.Sprintf("%d/%d checks", passed, m.checkTotal))
}

func (m model) Init() tea.Cmd { return tea.Batch(tickCmd(), checkClusterCmd()) }

func tickCmd() tea.Cmd {
	return tea.Tick(time.Second, func(t time.Time) tea.Msg { return tickMsg(t) })
}

func confettiTickCmd() tea.Cmd {
	return tea.Tick(70*time.Millisecond, func(t time.Time) tea.Msg { return confettiTickMsg(t) })
}

const watchInterval = 1 * time.Second

func watchTickCmd(idx int) tea.Cmd {
	return tea.Tick(watchInterval, func(time.Time) tea.Msg { return watchTickMsg{idx: idx} })
}

// runWatch runs a verify script quietly in the background (no live streaming)
// and reports pass/fail along with its captured output, for the live-verify
// watch loop.
func runWatch(path string, idx int) tea.Cmd {
	return func() tea.Msg {
		cmd := scriptCommand(path)
		cmd.Env = os.Environ()
		out, err := cmd.CombinedOutput()
		return watchResultMsg{idx: idx, passed: err == nil, output: splitLines(out)}
	}
}

func splitLines(b []byte) []string {
	s := strings.TrimRight(string(b), "\n")
	if s == "" {
		return nil
	}
	lines := strings.Split(s, "\n")
	for i := range lines {
		lines[i] = strings.TrimRight(lines[i], "\r")
	}
	return lines
}

// markPassed records a solved exercise and returns true if this is a new pass.
func (m *model) markPassed(idx int, passed bool) bool {
	dir := m.exercises[idx].DirName
	was := m.passed[dir]
	if passed && !was {
		m.passed[dir] = true
		m.rebuildList()
		return true
	}
	if !passed && was {
		// A previously-solved exercise regressed (e.g. live verify now fails).
		m.passed[dir] = false
		m.rebuildList()
	}
	return false
}

// celebrate kicks off the confetti overlay. Returns a tick cmd if started.
func (m *model) celebrate() tea.Cmd {
	w, h := m.width, m.height
	if w <= 0 || h <= 0 {
		return nil
	}
	m.confetti.start(w, h)
	if m.confetti.active {
		return confettiTickCmd()
	}
	return nil
}

func (m model) elapsed() time.Duration {
	d := m.timerAccum
	if m.timerRunning {
		d += time.Since(m.timerStart)
	}
	return d
}

func (m *model) toggleTimer() {
	if m.timerRunning {
		m.timerAccum += time.Since(m.timerStart)
		m.timerRunning = false
	} else {
		m.timerStart = time.Now()
		m.timerRunning = true
	}
}

func (m *model) resetTimer() {
	m.timerAccum = 0
	m.timerStart = time.Now()
}

func (m *model) buildRenderer(width int) {
	r, err := glamour.NewTermRenderer(
		glamour.WithAutoStyle(),
		glamour.WithWordWrap(width),
	)
	if err == nil {
		m.renderer = r
	}
}

func (m model) detailMarkdown() string {
	ex := m.exercises[m.current]
	var b strings.Builder
	b.WriteString(ex.Body)
	b.WriteString("\n\n")

	if len(ex.Hints) > 0 {
		b.WriteString("## Hints\n\n")
		if m.revealed == 0 {
			b.WriteString(fmt.Sprintf("_%d hint(s) available. Press_ `n` _to reveal one at a time._\n", len(ex.Hints)))
		}
		for i := 0; i < m.revealed && i < len(ex.Hints); i++ {
			b.WriteString(fmt.Sprintf("**Hint %d**\n\n", i+1))
			b.WriteString(ex.Hints[i])
			b.WriteString("\n\n")
		}
		if m.revealed < len(ex.Hints) {
			b.WriteString(fmt.Sprintf("_%d more hint(s) hidden — press_ `n`.\n", len(ex.Hints)-m.revealed))
		}
	} else {
		b.WriteString("_No hints for this exercise._\n")
	}
	return b.String()
}

// consoleBlock returns the live verify output as a raw (ANSI-preserving) block,
// or "" when there is nothing to show. It is appended below the markdown.
func (m model) consoleBlock() string {
	if len(m.console) == 0 && !m.running {
		return ""
	}
	var b strings.Builder
	b.WriteString(consoleHeader.Render("──── verify output ────"))
	b.WriteByte('\n')
	if len(m.console) == 0 {
		b.WriteString(runStyle.Render("running…"))
	} else {
		b.WriteString(colorizeConsole(m.console))
		if m.running {
			b.WriteString("\n" + runStyle.Render("…"))
		}
	}
	return b.String()
}

func (m *model) refreshViewport() {
	md := m.detailMarkdown()
	rendered := md
	if m.renderer != nil {
		if out, err := m.renderer.Render(md); err == nil {
			rendered = out
		}
	}
	content := strings.TrimRight(rendered, "\n")
	if con := m.consoleBlock(); con != "" {
		content += "\n\n" + con
	}
	m.vp.SetContent(content)
}

func (m *model) openExercise(idx int) {
	if idx < 0 || idx >= len(m.exercises) {
		return
	}
	m.current = idx
	m.screen = screenDetail
	m.revealed = 0
	m.lastResult = nil
	m.setupMsg = ""
	m.console = nil
	m.resetChecks()
	m.vp.GotoTop()
	m.refreshViewport()
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
		m.list.SetSize(msg.Width, msg.Height-2)
		m.progress.Width = min(msg.Width-20, 50)

		vpWidth := msg.Width - 4
		if vpWidth < 20 {
			vpWidth = 20
		}
		m.buildRenderer(vpWidth)
		headerH := 2
		footerH := 4
		vpHeight := msg.Height - headerH - footerH
		if vpHeight < 3 {
			vpHeight = 3
		}
		if !m.ready {
			m.vp = viewport.New(vpWidth, vpHeight)
			m.ready = true
		} else {
			m.vp.Width = vpWidth
			m.vp.Height = vpHeight
		}
		if m.screen == screenDetail {
			m.refreshViewport()
		}
		return m, nil

	case tickMsg:
		return m, tickCmd()

	case clusterMsg:
		m.clusterKnown = true
		m.kubectlFound = msg.found
		m.clusterCtx = msg.context
		m.clusterReachable = msg.reachable
		return m, clusterTickCmd()

	case clusterTickMsg:
		return m, checkClusterCmd()

	case confettiTickMsg:
		if m.confetti.active {
			m.confetti.update()
			if m.confetti.active {
				return m, confettiTickCmd()
			}
		}
		return m, nil

	case watchTickMsg:
		if m.watchIdx != msg.idx {
			return m, nil // watch turned off or switched
		}
		if m.running && msg.idx == m.current {
			return m, watchTickCmd(msg.idx) // avoid clashing with a manual run
		}
		return m, runWatch(m.exercises[msg.idx].VerifyPath, msg.idx)

	case watchResultMsg:
		m.watchHasRes = true
		m.watchResIdx = msg.idx
		m.watchResultOK = msg.passed
		newly := m.markPassed(msg.idx, msg.passed)
		var cmds []tea.Cmd
		if msg.idx == m.current && m.screen == screenDetail {
			// Surface the verification output the moment watch sees it pass
			// (and only on the fail→pass transition, so we don't fight scroll).
			if msg.passed && !m.running && (m.lastResult == nil || !m.lastResult.passed) {
				m.console = msg.output
				m.resetChecks()
				for _, l := range msg.output {
					m.parseCheck(l)
				}
				r := verifyDoneMsg{passed: true, exitCode: 0}
				m.lastResult = &r
				m.refreshViewport()
				m.vp.GotoBottom()
			}
			if newly {
				if c := m.celebrate(); c != nil {
					cmds = append(cmds, c)
				}
			}
		}
		if m.watchIdx == msg.idx {
			cmds = append(cmds, watchTickCmd(msg.idx))
		}
		return m, tea.Batch(cmds...)

	case streamMsg:
		if msg.done {
			m.running = false
			r := msg.result
			m.lastResult = &r
			newly := m.markPassed(m.current, r.passed)
			if m.screen == screenDetail {
				m.refreshViewport()
				m.vp.GotoBottom()
			}
			if newly && m.screen == screenDetail {
				if c := m.celebrate(); c != nil {
					return m, c
				}
			}
			return m, nil
		}
		m.console = append(m.console, msg.line)
		m.parseCheck(msg.line)
		if m.screen == screenDetail {
			m.refreshViewport()
			m.vp.GotoBottom()
		}
		return m, waitForStream(m.stream)

	case setupDoneMsg:
		m.running = false
		if msg.err != nil {
			m.setupMsg = "setup failed: " + msg.err.Error()
		} else {
			m.setupMsg = "setup complete"
		}
		return m, nil

	case tea.KeyMsg:
		// While the celebration is up, any key dismisses it.
		if m.confetti.active {
			m.confetti.active = false
			return m, nil
		}
		switch m.screen {
		case screenList:
			return m.updateList(msg)
		case screenDetail:
			return m.updateDetail(msg)
		}
	}

	var cmd tea.Cmd
	if m.screen == screenList {
		m.list, cmd = m.list.Update(msg)
	} else {
		m.vp, cmd = m.vp.Update(msg)
	}
	return m, cmd
}

func (m model) updateList(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	if m.list.FilterState() == list.Filtering {
		var cmd tea.Cmd
		m.list, cmd = m.list.Update(msg)
		return m, cmd
	}

	switch msg.String() {
	case "q", "ctrl+c":
		return m, tea.Quit
	case "r":
		m.clusterKnown = false
		return m, checkClusterCmd()
	case "t":
		m.toggleTimer()
		return m, nil
	case "T":
		m.resetTimer()
		return m, nil
	case "enter", "l", "right":
		if _, ok := m.list.SelectedItem().(exItem); ok {
			m.openExercise(m.list.Index())
			return m, nil
		}
	}

	var cmd tea.Cmd
	m.list, cmd = m.list.Update(msg)
	return m, cmd
}

func (m model) updateDetail(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "q", "ctrl+c":
		return m, tea.Quit
	case "esc", "backspace", "h", "left":
		m.screen = screenList
		m.list.Select(m.current)
		return m, nil
	case "]", "L":
		if m.current < len(m.exercises)-1 {
			m.openExercise(m.current + 1)
		}
		return m, nil
	case "[", "H":
		if m.current > 0 {
			m.openExercise(m.current - 1)
		}
		return m, nil
	case "n":
		ex := m.exercises[m.current]
		if m.revealed < len(ex.Hints) {
			m.revealed++
			m.refreshViewport()
		}
		return m, nil
	case "N":
		if m.revealed > 0 {
			m.revealed = 0
			m.refreshViewport()
		}
		return m, nil
	case "w":
		ex := m.exercises[m.current]
		if ex.VerifyPath == "" {
			return m, nil
		}
		if m.watchIdx == m.current {
			m.watchIdx = -1 // toggle off
			return m, nil
		}
		m.watchIdx = m.current
		return m, runWatch(ex.VerifyPath, m.current) // immediate first run
	case "v", "enter":
		ex := m.exercises[m.current]
		if ex.VerifyPath == "" || m.running {
			return m, nil
		}
		m.running = true
		m.lastResult = nil
		m.console = nil
		m.resetChecks()
		m.stream = make(chan streamMsg, 1024)
		startScript(ex.VerifyPath, m.stream)
		m.refreshViewport()
		m.vp.GotoBottom()
		return m, waitForStream(m.stream)
	case "s":
		ex := m.exercises[m.current]
		if ex.SetupPath == "" || m.running {
			return m, nil
		}
		m.running = true
		m.setupMsg = ""
		return m, runSetup(ex.SetupPath)
	}

	var cmd tea.Cmd
	m.vp, cmd = m.vp.Update(msg)
	return m, cmd
}

// scriptCommand builds a command that runs a script honoring its shebang,
// exactly like executing it in a terminal. This matters because forcing a bare
// "bash" would pick up whichever bash is first on PATH (often Homebrew bash 5.x
// on macOS), which disagrees with the shebang's /bin/bash (3.2) on things like
// `set -e` combined with `((x++))` — causing scripts to abort early only inside
// the TUI. Honoring the shebang keeps TUI behavior identical to the terminal.
func scriptCommand(path string) *exec.Cmd {
	interp, args := shebang(path)
	cmd := exec.Command(interp, append(args, path)...)
	cmd.Dir = dirOf(path)
	return cmd
}

// shebang returns the interpreter and its arguments from the file's first line,
// defaulting to /bin/bash when there is no usable shebang.
func shebang(path string) (string, []string) {
	f, err := os.Open(path)
	if err != nil {
		return "/bin/bash", nil
	}
	defer func() { _ = f.Close() }()
	line, _ := bufio.NewReader(f).ReadString('\n')
	line = strings.TrimRight(line, "\r\n")
	if strings.HasPrefix(line, "#!") {
		if fields := strings.Fields(line[2:]); len(fields) > 0 {
			return fields[0], fields[1:]
		}
	}
	return "/bin/bash", nil
}

// startScript runs a script under a PTY so colored/TTY-aware output is
// preserved, streaming each line into ch and finishing with a done message.
func startScript(path string, ch chan streamMsg) {
	go func() {
		cmd := scriptCommand(path)
		cmd.Env = append(os.Environ(),
			"TERM=xterm-256color",
			"FORCE_COLOR=1",
			"CLICOLOR_FORCE=1",
		)

		ptmx, err := pty.Start(cmd)
		if err != nil {
			ch <- streamMsg{done: true, result: verifyDoneMsg{exitCode: -1, err: err}}
			return
		}
		defer func() { _ = ptmx.Close() }()

		scanner := bufio.NewScanner(ptmx)
		scanner.Buffer(make([]byte, 0, 64*1024), 1024*1024)
		for scanner.Scan() {
			ch <- streamMsg{line: strings.TrimRight(scanner.Text(), "\r")}
		}

		werr := cmd.Wait()
		exitCode := 0
		passed := werr == nil
		if ee, ok := werr.(*exec.ExitError); ok {
			exitCode = ee.ExitCode()
		} else if werr != nil {
			exitCode = -1
		}
		ch <- streamMsg{done: true, result: verifyDoneMsg{passed: passed, exitCode: exitCode, err: werr}}
	}()
}

func waitForStream(ch chan streamMsg) tea.Cmd {
	return func() tea.Msg { return <-ch }
}

func runSetup(path string) tea.Cmd {
	return func() tea.Msg {
		cmd := scriptCommand(path)
		cmd.Env = os.Environ()
		out, err := cmd.CombinedOutput()
		return setupDoneMsg{output: string(out), err: err}
	}
}

func dirOf(path string) string {
	i := strings.LastIndexByte(path, '/')
	if i < 0 {
		return "."
	}
	return path[:i]
}

func (m model) View() string {
	if !m.ready {
		return "Loading…"
	}
	if m.confetti.active {
		return m.confetti.render()
	}
	switch m.screen {
	case screenList:
		return m.listView()
	default:
		return m.detailView()
	}
}

func (m model) progressLine() string {
	done := 0
	for _, e := range m.exercises {
		if m.passed[e.DirName] {
			done++
		}
	}
	total := len(m.exercises)
	pct := 0.0
	if total > 0 {
		pct = float64(done) / float64(total)
	}
	bar := m.progress.ViewAs(pct)
	label := fmt.Sprintf(" %d/%d solved", done, total)
	left := lipgloss.JoinHorizontal(lipgloss.Center, bar, helpStyle.Render(label), "  ", m.timerView())
	return lipgloss.JoinHorizontal(lipgloss.Center, left, "   ", m.clusterView())
}

func (m model) timerView() string {
	state := "⏸"
	if m.timerRunning {
		state = "▶"
	}
	return timerStyle.Render(fmt.Sprintf("%s %s", state, fmtDur(m.elapsed())))
}

func (m model) listView() string {
	header := m.progressLine()
	return lipgloss.JoinVertical(lipgloss.Left, header, m.list.View())
}

func (m model) detailView() string {
	ex := m.exercises[m.current]
	pos := fmt.Sprintf(" [%d/%d]", m.current+1, len(m.exercises))
	header := titleStyle.Render(ex.Title + pos)

	body := paneStyle.Width(m.vp.Width).Render(m.vp.View())

	return lipgloss.JoinVertical(lipgloss.Left, header, body, m.detailFooter(ex))
}

func (m model) detailFooter(ex Exercise) string {
	var status string
	switch {
	case m.running:
		status = runStyle.Render("⟳ running…")
	case m.lastResult != nil:
		r := m.lastResult
		if r.passed {
			status = passStyle.Render("✓ PASS")
		} else {
			status = failStyle.Render(fmt.Sprintf("✗ FAIL (exit %d)", r.exitCode))
		}
	case m.setupMsg != "":
		status = runStyle.Render(m.setupMsg)
	default:
		status = helpStyle.Render("ready")
	}

	segs := []string{status, m.timerView()}
	if cv := m.checksView(); cv != "" {
		segs = append(segs, cv)
	}
	if m.watchIdx == m.current {
		w := watchStyle.Render(fmt.Sprintf("👁 watch %s", fmtDur(watchInterval)))
		if m.watchHasRes && m.watchResIdx == m.current {
			if m.watchResultOK {
				w += " " + passStyle.Render("passing")
			} else {
				w += " " + failStyle.Render("failing")
			}
		}
		segs = append(segs, w)
	}
	segs = append(segs, m.clusterView())
	statusLine := strings.Join(segs, "   ")

	keys := []string{"n hint", "v verify", "w watch"}
	if ex.SetupPath != "" {
		keys = append(keys, "s setup")
	}
	keys = append(keys, "[ ] prev·next", "esc back", "q quit")
	help := helpStyle.Render(strings.Join(keys, "  ·  "))

	return lipgloss.JoinVertical(lipgloss.Left, statusLine, help)
}

func fmtDur(d time.Duration) string {
	d = d.Round(time.Second)
	h := d / time.Hour
	d -= h * time.Hour
	mn := d / time.Minute
	d -= mn * time.Minute
	s := d / time.Second
	if h > 0 {
		return fmt.Sprintf("%d:%02d:%02d", h, mn, s)
	}
	return fmt.Sprintf("%02d:%02d", mn, s)
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

package main

import (
	"regexp"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

var (
	conHeaderStyle = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("51"))
	conPassStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("42"))
	conFailStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("203"))
	conDimStyle    = lipgloss.NewStyle().Foreground(lipgloss.Color("245"))
	conNumPass     = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("42"))
	conNumFail     = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("203"))
)

var resultsRe = regexp.MustCompile(`(?i)^(\s*results?:\s*)(\d+)(\s+passed,\s*)(\d+)(\s+failed.*)$`)

// colorizeLine adds color to a raw verify.sh output line. If the line already
// carries ANSI escapes (a script that colors its own output), it is left as-is
// so we never double-style.
func colorizeLine(line string) string {
	if strings.Contains(line, "\x1b[") {
		return line
	}
	trimmed := strings.TrimSpace(line)
	if trimmed == "" {
		return line
	}
	low := strings.ToLower(trimmed)

	// Results summary: "Results: 2 passed, 3 failed out of 5"
	if mt := resultsRe.FindStringSubmatch(line); mt != nil {
		return conDimStyle.Render(mt[1]) +
			conNumPass.Render(mt[2]) +
			conDimStyle.Render(mt[3]) +
			conNumFail.Render(mt[4]) +
			conDimStyle.Render(mt[5])
	}

	switch {
	case strings.HasPrefix(trimmed, "===") || strings.HasPrefix(trimmed, "---") || strings.HasPrefix(trimmed, "#"):
		return conHeaderStyle.Render(line)
	case strings.Contains(line, "PASS") || strings.Contains(trimmed, "✓"):
		return conPassStyle.Render(line)
	case strings.Contains(line, "FAIL") || strings.Contains(trimmed, "✗") ||
		strings.Contains(low, "error") || strings.Contains(low, "not found"):
		return conFailStyle.Render(line)
	default:
		return line
	}
}

func colorizeConsole(lines []string) string {
	out := make([]string, len(lines))
	for i, l := range lines {
		out[i] = colorizeLine(l)
	}
	return strings.Join(out, "\n")
}

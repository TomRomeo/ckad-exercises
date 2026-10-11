package main

import (
	"context"
	"os/exec"
	"strings"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// clusterMsg reports the result of a kubectl connectivity preflight check.
type clusterMsg struct {
	found     bool // kubectl binary present
	context   string
	reachable bool
}

type clusterTickMsg time.Time

const clusterRefresh = 15 * time.Second

var (
	clusterOKStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("42"))
	clusterBadStyle  = lipgloss.NewStyle().Foreground(lipgloss.Color("196"))
	clusterCtxStyle  = lipgloss.NewStyle().Foreground(lipgloss.Color("111"))
	clusterWarnStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("214"))
)

func clusterTickCmd() tea.Cmd {
	return tea.Tick(clusterRefresh, func(t time.Time) tea.Msg { return clusterTickMsg(t) })
}

// checkClusterCmd probes kubectl for the current context and whether the API
// server is reachable, using short timeouts so the UI never blocks.
func checkClusterCmd() tea.Cmd {
	return func() tea.Msg {
		path, err := exec.LookPath("kubectl")
		if err != nil {
			return clusterMsg{found: false}
		}

		cctx := kubectlOutput(path, 3*time.Second, "config", "current-context")

		c, cancel := context.WithTimeout(context.Background(), 4*time.Second)
		defer cancel()
		health := exec.CommandContext(c, path, "get", "--raw=/healthz", "--request-timeout=3s")
		reachable := health.Run() == nil

		return clusterMsg{found: true, context: strings.TrimSpace(cctx), reachable: reachable}
	}
}

func kubectlOutput(path string, timeout time.Duration, args ...string) string {
	c, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	out, err := exec.CommandContext(c, path, args...).Output()
	if err != nil {
		return ""
	}
	return string(out)
}

// clusterView renders the compact preflight banner shown in the header/footer.
func (m model) clusterView() string {
	if !m.clusterKnown {
		return clusterWarnStyle.Render("⎈ checking cluster…")
	}
	if !m.kubectlFound {
		return clusterBadStyle.Render("⎈ kubectl not found")
	}
	ctxName := m.clusterCtx
	if ctxName == "" {
		ctxName = "(no context)"
	}
	label := clusterCtxStyle.Render("⎈ " + ctxName)
	if m.clusterReachable {
		return label + " " + clusterOKStyle.Render("● reachable")
	}
	return label + " " + clusterBadStyle.Render("✗ unreachable")
}

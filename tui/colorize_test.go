package main

import (
	"strings"
	"testing"

	"github.com/charmbracelet/lipgloss"
	"github.com/muesli/termenv"
)

func TestColorizeLine(t *testing.T) {
	// Force a color profile; go test runs without a TTY so lipgloss would
	// otherwise strip all styling and make these assertions meaningless.
	prev := lipgloss.ColorProfile()
	lipgloss.SetColorProfile(termenv.ANSI256)
	defer lipgloss.SetColorProfile(prev)

	cases := []struct {
		in       string
		colored  bool // expect ANSI applied
		contains string
	}{
		{"=== Verifying Exercise 01 ===", true, ""},
		{"Check 1/5 - Pod exists: PASS", true, ""},
		{"Check 2/5 - Image is nginx:1.25: FAIL (image: 'not found')", true, ""},
		{"", false, ""},
		{"plain informational line", false, ""},
		{"\x1b[33malready colored\x1b[0m", true, "already colored"}, // left untouched
	}
	for _, c := range cases {
		got := colorizeLine(c.in)
		hasANSI := strings.Contains(got, "\x1b[")
		if hasANSI != c.colored {
			t.Errorf("colorizeLine(%q): ANSI=%v, want %v (got %q)", c.in, hasANSI, c.colored, got)
		}
	}

	// Pre-colored input must be returned verbatim (no double styling).
	pre := "\x1b[33malready colored\x1b[0m"
	if colorizeLine(pre) != pre {
		t.Errorf("pre-colored line should be unchanged")
	}

	// Results line should color the passed and failed counts distinctly.
	res := colorizeLine("Results: 2 passed, 3 failed out of 5")
	if strings.Count(res, "\x1b[") < 4 {
		t.Errorf("results line should style multiple segments, got %q", res)
	}
	if !strings.Contains(stripANSI(res), "2 passed, 3 failed out of 5") {
		t.Errorf("results text should be preserved, got %q", stripANSI(res))
	}
}

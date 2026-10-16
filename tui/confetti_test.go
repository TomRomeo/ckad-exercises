package main

import (
	"strings"
	"testing"
)

func TestConfettiLifecycle(t *testing.T) {
	c := newConfetti()
	c.start(80, 24)
	if !c.active {
		t.Fatal("confetti should be active after start")
	}
	if len(c.parts) == 0 {
		t.Fatal("expected particles")
	}

	// Render should produce exactly height lines and never panic.
	out := c.render()
	if got := strings.Count(out, "\n") + 1; got != 24 {
		t.Errorf("expected 24 rendered lines, got %d", got)
	}
	if !strings.Contains(stripANSI(out), "ALL CHECKS PASSED") {
		t.Error("banner missing from confetti frame")
	}

	// It must terminate within the frame cap.
	for i := 0; i < confettiMaxFrames+5 && c.active; i++ {
		c.update()
	}
	if c.active {
		t.Error("confetti should auto-deactivate within the frame cap")
	}
}

func TestMarkPassedNewlyAndRegression(t *testing.T) {
	m := newModel([]Exercise{
		{DirName: "01-easy-a", Title: "A"},
		{DirName: "02-easy-b", Title: "B"},
	})

	if !m.markPassed(0, true) {
		t.Error("first pass should be reported as newly solved")
	}
	if m.markPassed(0, true) {
		t.Error("re-passing an already-solved exercise is not newly solved")
	}
	if !m.passed["01-easy-a"] {
		t.Error("exercise should be marked solved")
	}
	// Regression: a watched exercise that starts failing again.
	if m.markPassed(0, false) {
		t.Error("regression should not count as newly solved")
	}
	if m.passed["01-easy-a"] {
		t.Error("exercise should be unmarked after regression")
	}
}

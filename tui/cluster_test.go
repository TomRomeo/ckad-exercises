package main

import (
	"strings"
	"testing"
)

func TestParseCheckProgress(t *testing.T) {
	m := newModel([]Exercise{{DirName: "01-easy-a", Title: "A"}})

	// Lines in the exact shape the repo's verify.sh scripts emit, including a
	// colored variant to confirm ANSI is stripped before matching.
	lines := []string{
		"=== Verifying Exercise 01 ===",
		"Check 1/5 - Pod 'web-pod' exists and is Running: PASS",
		"Check 2/5 - Image is nginx:1.25: FAIL (image: 'not found')",
		"\x1b[32mCheck 3/5 - Labels app=web and tier=frontend: PASS\x1b[0m",
		"Results: 2 passed, 1 failed out of 5",
	}
	for _, l := range lines {
		m.parseCheck(l)
	}

	if m.checkTotal != 5 {
		t.Fatalf("expected total 5, got %d", m.checkTotal)
	}
	if m.checks[0] != checkPass {
		t.Errorf("check 1 should be pass")
	}
	if m.checks[1] != checkFail {
		t.Errorf("check 2 should be fail")
	}
	if m.checks[2] != checkPass {
		t.Errorf("check 3 (colored) should be pass")
	}
	if m.checks[3] != checkPending || m.checks[4] != checkPending {
		t.Errorf("checks 4 and 5 should remain pending")
	}

	view := m.checksView()
	if !strings.Contains(view, "2/5 checks") {
		t.Errorf("checksView should report 2/5, got %q", stripANSI(view))
	}

	m.resetChecks()
	if m.checkTotal != 0 || m.checks != nil {
		t.Error("resetChecks should clear state")
	}
	if m.checksView() != "" {
		t.Error("checksView should be empty with no checks")
	}
}

func TestClusterView(t *testing.T) {
	m := newModel([]Exercise{{DirName: "01-easy-a", Title: "A"}})

	if got := stripANSI(m.clusterView()); !strings.Contains(got, "checking") {
		t.Errorf("unknown cluster state should show 'checking', got %q", got)
	}

	m.clusterKnown = true
	m.kubectlFound = false
	if got := stripANSI(m.clusterView()); !strings.Contains(got, "kubectl not found") {
		t.Errorf("missing kubectl state, got %q", got)
	}

	m.kubectlFound = true
	m.clusterCtx = "minikube"
	m.clusterReachable = true
	if got := stripANSI(m.clusterView()); !strings.Contains(got, "minikube") || !strings.Contains(got, "reachable") {
		t.Errorf("reachable state, got %q", got)
	}

	m.clusterReachable = false
	if got := stripANSI(m.clusterView()); !strings.Contains(got, "unreachable") {
		t.Errorf("unreachable state, got %q", got)
	}
}

func stripANSI(s string) string { return ansiRe.ReplaceAllString(s, "") }

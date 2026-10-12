package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestShebangParsing(t *testing.T) {
	dir := t.TempDir()

	cases := []struct {
		name     string
		first    string
		wantInt  string
		wantArgs int
	}{
		{"plain-bash", "#!/bin/bash\n", "/bin/bash", 0},
		{"env-bash", "#!/usr/bin/env bash\n", "/usr/bin/env", 1},
		{"sh", "#!/bin/sh -e\n", "/bin/sh", 1},
		{"none", "echo hi\n", "/bin/bash", 0}, // default
	}
	for _, c := range cases {
		p := filepath.Join(dir, c.name+".sh")
		if err := os.WriteFile(p, []byte(c.first+"echo hi\n"), 0o755); err != nil {
			t.Fatal(err)
		}
		interp, args := shebang(p)
		if interp != c.wantInt {
			t.Errorf("%s: interp=%q want %q", c.name, interp, c.wantInt)
		}
		if len(args) != c.wantArgs {
			t.Errorf("%s: args=%v want %d", c.name, args, c.wantArgs)
		}
	}
}

// TestSetEIncrementCompat guards the actual bug: a script using `set -e` with
// `((x++))` must run to completion when executed the way the TUI runs it
// (honoring the shebang), the same as it does from the terminal.
func TestSetEIncrementCompat(t *testing.T) {
	dir := t.TempDir()
	p := filepath.Join(dir, "inc.sh")
	script := "#!/bin/bash\nset -euo pipefail\nx=0\n((x++))\n((x++))\necho \"done x=$x\"\n"
	if err := os.WriteFile(p, []byte(script), 0o755); err != nil {
		t.Fatal(err)
	}

	cmd := scriptCommand(p)
	out, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("script aborted early (the exercise-19 bug): %v\noutput: %s", err, out)
	}
	if string(out) != "done x=2\n" {
		t.Errorf("unexpected output: %q", out)
	}
}

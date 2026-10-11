package main

import (
	"os"
	"path/filepath"
	"testing"
	"time"
)

func TestStartScriptStreaming(t *testing.T) {
	dir := t.TempDir()
	script := filepath.Join(dir, "demo.sh")
	content := "#!/bin/bash\n" +
		"echo line-one\n" +
		"printf '\\033[32mgreen-line\\033[0m\\n'\n" + // colored output via ANSI
		"echo line-three\n" +
		"exit 3\n"
	if err := os.WriteFile(script, []byte(content), 0o755); err != nil {
		t.Fatal(err)
	}

	ch := make(chan streamMsg, 64)
	startScript(script, ch)

	var lines []string
	var done *streamMsg
	timeout := time.After(10 * time.Second)
	for done == nil {
		select {
		case msg := <-ch:
			if msg.done {
				d := msg
				done = &d
			} else {
				lines = append(lines, msg.line)
			}
		case <-timeout:
			t.Fatal("timed out waiting for script output")
		}
	}

	if len(lines) < 3 {
		t.Fatalf("expected >=3 lines, got %d: %v", len(lines), lines)
	}
	if done.result.exitCode != 3 {
		t.Errorf("expected exit code 3, got %d", done.result.exitCode)
	}
	if done.result.passed {
		t.Errorf("expected passed=false for non-zero exit")
	}
	// ANSI color codes must be preserved in the stream.
	joined := ""
	for _, l := range lines {
		joined += l
	}
	if !containsEsc(joined) {
		t.Errorf("expected ANSI escape codes to be preserved, got: %q", joined)
	}
}

func containsEsc(s string) bool {
	for i := 0; i < len(s); i++ {
		if s[i] == 0x1b {
			return true
		}
	}
	return false
}

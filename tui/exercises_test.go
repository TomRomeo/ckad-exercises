package main

import "testing"

func TestLoadExercises(t *testing.T) {
	root, err := FindRoot("..")
	if err != nil {
		t.Fatalf("FindRoot: %v", err)
	}
	exs, err := LoadExercises(root)
	if err != nil {
		t.Fatalf("LoadExercises: %v", err)
	}
	if len(exs) != 40 {
		t.Fatalf("expected 40 exercises, got %d", len(exs))
	}
	e := exs[0]
	if e.Number != "01" || e.Difficulty != "easy" {
		t.Errorf("bad parse of first: num=%q diff=%q", e.Number, e.Difficulty)
	}
	if e.Title == "" || e.Body == "" {
		t.Errorf("empty title/body for %s", e.DirName)
	}
	if len(e.Hints) != 3 {
		t.Errorf("expected 3 hints for ex01, got %d", len(e.Hints))
	}
	if e.VerifyPath == "" {
		t.Errorf("missing verify path for ex01")
	}
	// Body must not contain the hints section.
	for _, ex := range exs {
		if ex.VerifyPath == "" {
			t.Errorf("%s missing verify.sh", ex.DirName)
		}
	}
}

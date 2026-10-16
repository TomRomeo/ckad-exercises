package main

import (
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"
)

func main() {
	start := "."
	if len(os.Args) > 1 {
		start = os.Args[1]
	}

	root, err := FindRoot(start)
	if err != nil {
		fmt.Fprintln(os.Stderr, "could not locate CKAD exercises directory:", err)
		fmt.Fprintln(os.Stderr, "run this from inside the repo, or pass the repo path as an argument.")
		os.Exit(1)
	}

	exs, err := LoadExercises(root)
	if err != nil {
		fmt.Fprintln(os.Stderr, "failed to load exercises:", err)
		os.Exit(1)
	}
	if len(exs) == 0 {
		fmt.Fprintln(os.Stderr, "no exercises found in", root)
		os.Exit(1)
	}

	p := tea.NewProgram(newModel(exs), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
}

package main

import (
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

// Exercise represents a single CKAD practice exercise discovered on disk.
type Exercise struct {
	Dir        string // absolute path to the exercise directory
	DirName    string // e.g. "01-easy-pod-design"
	Number     string // e.g. "01"
	Difficulty string // easy / medium / hard (best-effort, from dir name)
	Title      string // H1 from README, falls back to prettified dir name
	Body       string // markdown before the "## Hints" section
	Hints      []string
	SetupPath  string // path to setup.sh if present
	VerifyPath string // path to verify.sh if present
}

var (
	exDirRe   = regexp.MustCompile(`^(\d{2})-([a-z]+)-(.+)$`)
	detailsRe = regexp.MustCompile(`(?s)<details>(.*?)</details>`)
	summaryRe = regexp.MustCompile(`(?s)<summary>.*?</summary>`)
	h1Re      = regexp.MustCompile(`(?m)^#\s+(.+)$`)
)

// FindRoot locates the repository root by walking up from start until it finds
// a directory that contains at least one exercise directory (NN-...).
func FindRoot(start string) (string, error) {
	dir, err := filepath.Abs(start)
	if err != nil {
		return "", err
	}
	for {
		entries, err := os.ReadDir(dir)
		if err == nil {
			for _, e := range entries {
				if e.IsDir() && exDirRe.MatchString(e.Name()) {
					return dir, nil
				}
			}
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return "", os.ErrNotExist
		}
		dir = parent
	}
}

// LoadExercises scans root for exercise directories and parses each README.
func LoadExercises(root string) ([]Exercise, error) {
	entries, err := os.ReadDir(root)
	if err != nil {
		return nil, err
	}

	var out []Exercise
	for _, e := range entries {
		if !e.IsDir() || !exDirRe.MatchString(e.Name()) {
			continue
		}
		dir := filepath.Join(root, e.Name())
		ex := parseExercise(dir, e.Name())
		out = append(out, ex)
	}

	sort.Slice(out, func(i, j int) bool {
		return out[i].DirName < out[j].DirName
	})
	return out, nil
}

func parseExercise(dir, dirName string) Exercise {
	ex := Exercise{Dir: dir, DirName: dirName}

	if m := exDirRe.FindStringSubmatch(dirName); m != nil {
		ex.Number = m[1]
		ex.Difficulty = m[2]
	}

	if p := filepath.Join(dir, "setup.sh"); fileExists(p) {
		ex.SetupPath = p
	}
	if p := filepath.Join(dir, "verify.sh"); fileExists(p) {
		ex.VerifyPath = p
	}

	raw, err := os.ReadFile(filepath.Join(dir, "README.md"))
	content := string(raw)
	if err != nil {
		content = "_No README.md found for this exercise._"
	}

	// Title from first H1.
	if m := h1Re.FindStringSubmatch(content); m != nil {
		ex.Title = strings.TrimSpace(m[1])
	} else {
		ex.Title = prettify(dirName)
	}

	// Split body / hints on the "## Hints" heading.
	body := content
	hintsSection := ""
	if idx := indexOfHeading(content, "Hints"); idx >= 0 {
		body = content[:idx]
		hintsSection = content[idx:]
	}
	ex.Body = strings.TrimSpace(body)
	ex.Hints = parseHints(hintsSection)

	return ex
}

// parseHints extracts the inner markdown of each <details> block, stripping the
// <summary> label so only the actual hint content remains.
func parseHints(section string) []string {
	var hints []string
	for _, m := range detailsRe.FindAllStringSubmatch(section, -1) {
		inner := summaryRe.ReplaceAllString(m[1], "")
		inner = strings.TrimSpace(inner)
		if inner != "" {
			hints = append(hints, inner)
		}
	}
	return hints
}

// indexOfHeading returns the byte offset of a markdown heading like "## Name".
func indexOfHeading(content, name string) int {
	re := regexp.MustCompile(`(?m)^#{1,6}\s+` + regexp.QuoteMeta(name) + `\s*$`)
	loc := re.FindStringIndex(content)
	if loc == nil {
		return -1
	}
	return loc[0]
}

func prettify(dirName string) string {
	m := exDirRe.FindStringSubmatch(dirName)
	if m == nil {
		return dirName
	}
	words := strings.Split(m[3], "-")
	for i, w := range words {
		if w == "" {
			continue
		}
		words[i] = strings.ToUpper(w[:1]) + w[1:]
	}
	return "Exercise " + m[1] + ": " + strings.Join(words, " ")
}

func fileExists(p string) bool {
	info, err := os.Stat(p)
	return err == nil && !info.IsDir()
}

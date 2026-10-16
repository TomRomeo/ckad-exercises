package main

import (
	"math/rand"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

// confettiMaxFrames bounds the celebration length even if particles linger.
const confettiMaxFrames = 42

var confettiColors = []string{"196", "202", "214", "226", "46", "51", "45", "201", "213", "231"}
var confettiGlyphs = []rune{'*', 'o', '+', '•', '◆', '▪', '✦', '✺', '❄'}

type particle struct {
	x, y   float64
	vx, vy float64
	glyph  rune
	color  string
	life   int
}

type confetti struct {
	active bool
	frame  int
	w, h   int
	parts  []particle
	styles map[string]lipgloss.Style
}

func newConfetti() confetti {
	return confetti{styles: make(map[string]lipgloss.Style)}
}

func (c *confetti) start(w, h int) {
	if w <= 0 || h <= 0 {
		return
	}
	c.active = true
	c.frame = 0
	c.w, c.h = w, h
	n := w / 2
	if n < 40 {
		n = 40
	}
	if n > 160 {
		n = 160
	}
	c.parts = make([]particle, 0, n)
	for i := 0; i < n; i++ {
		c.parts = append(c.parts, particle{
			x:     rand.Float64() * float64(w),
			y:     rand.Float64()*float64(h)/3 - float64(h)/3, // start above the top
			vx:    (rand.Float64() - 0.5) * 1.6,
			vy:    0.25 + rand.Float64()*0.9,
			glyph: confettiGlyphs[rand.Intn(len(confettiGlyphs))],
			color: confettiColors[rand.Intn(len(confettiColors))],
			life:  18 + rand.Intn(20),
		})
	}
}

func (c *confetti) update() {
	if !c.active {
		return
	}
	c.frame++
	alive := c.parts[:0]
	for _, p := range c.parts {
		p.vy += 0.07 // gravity
		p.x += p.vx
		p.y += p.vy
		p.life--
		if p.life > 0 && p.y < float64(c.h) {
			alive = append(alive, p)
		}
	}
	c.parts = alive
	if c.frame >= confettiMaxFrames || len(c.parts) == 0 {
		c.active = false
	}
}

func (c *confetti) style(color string) lipgloss.Style {
	if s, ok := c.styles[color]; ok {
		return s
	}
	s := lipgloss.NewStyle().Foreground(lipgloss.Color(color))
	c.styles[color] = s
	return s
}

// render composites particles and a centered banner into a full-screen frame.
func (c *confetti) render() string {
	w, h := c.w, c.h
	if w <= 0 || h <= 0 {
		return ""
	}

	glyphGrid := make([][]rune, h)
	colorGrid := make([][]string, h)
	for y := 0; y < h; y++ {
		glyphGrid[y] = make([]rune, w)
		colorGrid[y] = make([]string, w)
		for x := 0; x < w; x++ {
			glyphGrid[y][x] = ' '
		}
	}

	for _, p := range c.parts {
		ix, iy := int(p.x), int(p.y)
		if ix >= 0 && ix < w && iy >= 0 && iy < h {
			glyphGrid[iy][ix] = p.glyph
			colorGrid[iy][ix] = p.color
		}
	}

	// Banner, centered.
	banner := []string{
		"🎉  ALL CHECKS PASSED!  🎉",
		"",
		"press any key to continue",
	}
	bannerColor := []string{"231", "", "245"}
	startY := h/2 - len(banner)/2
	for i, line := range banner {
		y := startY + i
		if y < 0 || y >= h {
			continue
		}
		runes := []rune(line)
		startX := (w - len(runes)) / 2
		for j, r := range runes {
			x := startX + j
			if x < 0 || x >= w {
				continue
			}
			glyphGrid[y][x] = r
			if r != ' ' {
				colorGrid[y][x] = bannerColor[i]
			} else {
				colorGrid[y][x] = ""
			}
		}
	}

	var out strings.Builder
	for y := 0; y < h; y++ {
		var row strings.Builder
		var pend strings.Builder
		pendColor := ""
		flush := func() {
			if pend.Len() == 0 {
				return
			}
			if pendColor == "" {
				row.WriteString(pend.String())
			} else {
				row.WriteString(c.style(pendColor).Render(pend.String()))
			}
			pend.Reset()
		}
		for x := 0; x < w; x++ {
			col := colorGrid[y][x]
			if col != pendColor {
				flush()
				pendColor = col
			}
			pend.WriteRune(glyphGrid[y][x])
		}
		flush()
		out.WriteString(row.String())
		if y < h-1 {
			out.WriteByte('\n')
		}
	}
	return out.String()
}

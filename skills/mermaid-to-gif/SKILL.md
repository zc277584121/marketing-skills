---
name: mermaid-to-gif
description: Convert Mermaid code blocks in .mmd or .md files to animated GIFs with customizable animation styles (progressive reveal, highlight walk, pulse flow, fade-in).
---

# Skill: Mermaid to GIF

Convert Mermaid diagrams into animated GIFs with rich animation effects. Supports `.mmd` files and extracting ` ```mermaid ` code blocks from `.md` files.

> **Prerequisites**: FFmpeg, Python 3.8+, Playwright (`pip install playwright && playwright install chromium`)

---

## When to Use

- The user wants to convert Mermaid diagrams to animated GIFs
- The user has `.mmd` files or `.md` files containing mermaid code blocks
- The user needs animated visuals for presentations, documentation, or social media
- The user wants to batch-convert all mermaid blocks in a document

---

## Default Workflow

### Single .mmd file

```bash
python ${CLAUDE_SKILL_ROOT}/scripts/mermaid_to_gif.py diagram.mmd
```

### Markdown file with mermaid blocks

```bash
python ${CLAUDE_SKILL_ROOT}/scripts/mermaid_to_gif.py document.md -o ./gifs/
```

This extracts all ` ```mermaid ` code blocks and generates one GIF per block.

### Multiple files

```bash
python ${CLAUDE_SKILL_ROOT}/scripts/mermaid_to_gif.py *.mmd -o ./gifs/
python ${CLAUDE_SKILL_ROOT}/scripts/mermaid_to_gif.py doc1.md doc2.md -o ./gifs/
```

---

## Animation Styles

| Style | Effect | Best For |
|-------|--------|----------|
| `progressive` (default) | Nodes and edges appear sequentially following diagram flow | Flowcharts, architecture diagrams |
| `highlight-walk` | All elements dimmed; a spotlight moves through each element in order | Step-by-step process explanations |
| `pulse-flow` | Edges show flowing dash animation, nodes pulse rhythmically | Data flow, pipeline diagrams |
| `fade-in` | Whole diagram fades in with easing | Simple reveals, title slides |

```bash
# Use highlight-walk style
python ${CLAUDE_SKILL_ROOT}/scripts/mermaid_to_gif.py diagram.mmd --style highlight-walk

# Use pulse-flow for pipeline diagrams
python ${CLAUDE_SKILL_ROOT}/scripts/mermaid_to_gif.py pipeline.mmd --style pulse-flow
```

---

## Common Options

| Flag | Default | Description |
|------|---------|-------------|
| `-o`, `--output-dir` | Same as input | Output directory for generated GIFs |
| `-s`, `--style` | `progressive` | Animation style (see table above) |
| `--fps` | `10` | Frames per second |
| `--duration` | `4.0` | Animation duration in seconds |
| `--hold` | `1.0` | Hold last frame before looping (seconds) |
| `--theme` | `default` | Mermaid theme: default, dark, forest, neutral |
| `--bg` | `#ffffff` | Background color (hex) |
| `--padding` | `30` | Padding around diagram in pixels |
| `--custom-css` | — | Path to custom CSS file |
| `--no-loop` | — | Play GIF once instead of looping |

---

## Examples

```bash
# Dark theme with faster animation
python ${CLAUDE_SKILL_ROOT}/scripts/mermaid_to_gif.py arch.mmd --theme dark --bg "#1a1a2e" --duration 3

# High FPS for smoother animation
python ${CLAUDE_SKILL_ROOT}/scripts/mermaid_to_gif.py flow.mmd --fps 15 --duration 5

# Batch convert all mermaid blocks from a doc
python ${CLAUDE_SKILL_ROOT}/scripts/mermaid_to_gif.py README.md -o ./images/

# Custom CSS for special effects
python ${CLAUDE_SKILL_ROOT}/scripts/mermaid_to_gif.py diagram.mmd --custom-css my-style.css

# No loop, suitable for one-time playback
python ${CLAUDE_SKILL_ROOT}/scripts/mermaid_to_gif.py intro.mmd --no-loop --duration 6
```

---

## Custom CSS

Create a CSS file to customize the appearance of the diagram during animation:

```css
/* Rounded nodes with shadow */
.node rect {
    rx: 10;
    filter: drop-shadow(2px 2px 4px rgba(0,0,0,0.3));
}

/* Thicker edge lines */
.edgePath path {
    stroke-width: 2.5;
}

/* Custom background for actors (sequence diagram) */
.actor {
    fill: #e8f4f8;
}
```

Pass it via `--custom-css`:

```bash
python ${CLAUDE_SKILL_ROOT}/scripts/mermaid_to_gif.py diagram.mmd --custom-css my-style.css
```

---

## How It Works

1. **Parse input** — extract Mermaid code from `.mmd` or `.md` files
2. **Generate HTML** — embed Mermaid.js (CDN) + animation JS/CSS in a self-contained HTML file
3. **Render** — Mermaid.js renders the diagram to SVG in headless Chromium via Playwright
4. **Animate** — JS animation engine exposes `setProgress(t)` for frame-by-frame control (t: 0→1)
5. **Capture** — Playwright takes a screenshot at each frame step
6. **Assemble** — FFmpeg two-pass palette encoding (palettegen → paletteuse with Floyd-Steinberg dithering)

The animation engine collects all SVG elements (nodes, edges, labels, clusters), sorts them by position respecting diagram flow direction (LR/TB), and assigns each element an appearance time. This creates a natural "building up" effect.

---

## Important Notes

- **Internet required**: Mermaid.js is loaded from CDN at render time
- **Supported diagram types**: flowchart, sequence, class, state, ER, gitgraph, mindmap, pie, gantt, and more
- **Fallback behavior**: for unrecognized diagram types or when no animatable elements are detected, falls back to a whole-diagram fade-in
- **Large diagrams**: complex diagrams produce more frames and larger GIFs — consider shorter `--duration` or lower `--fps`
- **GIF size**: for very large outputs, reduce FPS to 8, shorten duration, or use a simpler style like `fade-in`

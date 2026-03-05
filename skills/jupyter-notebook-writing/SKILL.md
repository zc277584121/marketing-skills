---
name: jupyter-notebook-writing
description: Write Milvus application-level Jupyter notebook examples using a Markdown-first workflow with jupyter-switch for format conversion.
---

# Skill: Jupyter Notebook Writing

Write Milvus application-level Jupyter notebook examples as a DevRel workflow. Uses a Markdown-first approach — AI edits `.md` files, then converts to `.ipynb` via `jupyter-switch`.

> **Prerequisites**: Python >= 3.10, uv (`uvx` command available)

---

## When to Use

The user wants to create or edit a Jupyter notebook example, typically demonstrating Milvus usage in an application context (RAG, semantic search, hybrid search, etc.).

---

## Core Workflow: Markdown-First Editing

Jupyter `.ipynb` files contain complex JSON with metadata, outputs, and execution counts — painful for AI to edit directly. Instead:

1. **Write/Edit the `.md` file** — AI works with clean Markdown
2. **Convert to `.ipynb`** — using `jupyter-switch` for runnable notebook
3. **Keep both files in sync** — the `.md` is the source of truth for editing

### Format Convention

In the `.md` file:
- **Python code blocks** (` ```python ... ``` `) become **code cells** in the notebook
- **Everything else** becomes **markdown cells**
- Cell outputs are not preserved in `.md` (they get generated when running the notebook)

### Conversion Commands

```bash
# Markdown -> Jupyter Notebook
uvx jupyter-switch example.md
# produces example.ipynb

# Jupyter Notebook -> Markdown
uvx jupyter-switch example.ipynb
# produces example.md
```

- The original input file is never modified or deleted
- If the output file already exists, a `.bak` backup is created automatically

---

## Step-by-Step

### Creating a New Notebook

1. Create `example.md` with the content (see structure below)
2. Convert: `uvx jupyter-switch example.md`
3. Both `example.md` and `example.ipynb` now exist

### Editing an Existing Notebook

1. If only `.ipynb` exists, convert first: `uvx jupyter-switch example.ipynb`
2. Edit the `.md` file
3. Convert back: `uvx jupyter-switch example.md`

### Testing / Running

1. Convert `.md` to `.ipynb` if needed
2. Run the notebook: `jupyter execute example.ipynb` or open in Jupyter UI
3. If errors found, fix in the `.md` file and re-convert

---

## Notebook Structure Template

A typical Milvus example notebook follows this structure:

```markdown
# Title

Brief description of what this notebook demonstrates.

## Prerequisites

Install dependencies:

` ``python
!pip install pymilvus some-other-package
` ``

## Setup

Import and configuration:

` ``python
from pymilvus import MilvusClient

client = MilvusClient(uri="http://localhost:19530")
` ``

## Prepare Data

Load or generate example data:

` ``python
# data preparation code
` ``

## Create Collection & Insert Data

` ``python
# collection creation and data insertion
` ``

## Query / Search

` ``python
# search or query examples
` ``

## Cleanup

` ``python
client.drop_collection("example_collection")
` ``
```

---

## Reference Documents

This skill includes two reference documents under `references/`. **Read them when the task involves their topics.**

| Reference | When to Read | File |
|-----------|-------------|------|
| **Bootcamp Format** | Writing a Milvus integration tutorial (badges, document structure, section format, example layout) | `references/bootcamp-format.md` |
| **Milvus Code Style** | Writing pymilvus code (collection creation, MilvusClient connection args, schema patterns, best practices) | `references/milvus-code-style.md` |

### Bootcamp Format (`references/bootcamp-format.md`)

Read this when the user is writing a **Milvus integration tutorial** for the bootcamp repository. It covers:
- Badge format (Colab + GitHub badges at the top)
- Document structure: Header -> Prerequisites -> Main Content -> Conclusion
- Dependency install format with Google Colab restart note
- API key placeholder conventions (`"sk-***********"`)
- Each code block should have a short text introduction before it

### Milvus Code Style (`references/milvus-code-style.md`)

Read this when the notebook involves **pymilvus code**. Key rules:
- Two ways to create collections: simple (just dimension) vs complex (explicit schema + index)
- Include `has_collection` check before creating collections
- Add commented `consistency_level="Strong"` line in `create_collection()`
- No need to call `load_collection()` — collections auto-load on creation
- First MilvusClient connection must include the blockquote explaining `uri` options (Milvus Lite / Docker / Zilliz Cloud)

---

## Important Notes

- **Always edit the `.md` file**, not the `.ipynb` directly. The `.md` is easier for AI to read and write.
- **Keep both files** — `.md` for editing, `.ipynb` for running/sharing.
- After editing `.md`, always re-run `uvx jupyter-switch example.md` to sync the `.ipynb`.

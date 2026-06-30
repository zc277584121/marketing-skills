---
name: my-milvus-integration
description: "Integrate Milvus into third-party Python projects and prepare upstream PRs. Use when asked to add, redo, review, or upstream a Milvus/Zilliz backend for an open-source Python project."
---

# Milvus Integration Workflow

Use this for Python open-source projects where the goal is an upstream Milvus or Zilliz Cloud integration PR.

## 1. Evaluate before coding

1. Read project guidance first: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, `pyproject.toml`, and relevant `docs/`.
2. Check existing Milvus work before editing:
   ```bash
   gh pr list --repo <owner>/<repo> --state all --search "milvus"
   gh issue list --repo <owner>/<repo> --state all --search "milvus"
   ```
3. If an open or recently closed Milvus PR exists, pause and report status, conflicts, and whether it should be replaced, rescued, or abandoned.
4. Classify the project architecture:
   - Existing backend/provider abstraction: add a Milvus provider.
   - Hardcoded backend but clear boundary: propose abstraction plus Milvus provider.
   - Scattered or coupled storage logic: pause and ask whether to proceed.
5. Report the plan before implementation: abstraction entry point, dependency strategy, tests, docs, risks, and PR value.

## 2. Environment and dependencies

1. Work inside the sub-project, not the monorepo root.
2. Prefer the project's own workflow. For uv projects, use:
   ```bash
   uv sync
   ```
3. Prefer `pymilvus` plus `milvus-lite` where supported, while following the project's dependency conventions.
4. Do not add heavy model dependencies unless the project already requires them. Prefer the project's existing embedding path; if OpenAI embeddings are already supported, use that for E2E checks.

## 3. Implement the provider

1. Use `pymilvus.MilvusClient`. Do not use ORM-style APIs such as `connections.connect()`, `Collection()`, `FieldSchema()`, `CollectionSchema()`, or `utility.has_collection()` in new code.
2. Default to Milvus Lite for local-first projects when that matches product behavior. Expose URI/token configuration so users can switch to Milvus server or Zilliz Cloud.
3. Follow project naming conventions for config keys. Prefer project-scoped env vars when the project already uses provider-prefixed settings.
4. Check whether `db_name` and `consistency_level` should be exposed for cloud, multi-database, or read-after-write-sensitive deployments.
5. Keep `namespace` and `db_name` separate: `db_name` is Milvus logical database selection; namespace is application-level collection naming or tenant isolation.
6. Decide Milvus' role before implementing advanced retrieval: pure vector search, full-text/BM25, hybrid search, and reranking should follow the project's existing abstraction instead of being added just because Milvus supports them.
7. Use explicit schemas and `AUTOINDEX` for dense vectors. Do not hardcode vector dimension unless the project already fixes embedding dimension.
8. When reusing an existing collection, inspect schema and vector dimension before writes/searches. Raise a clear error on mismatch instead of corrupting or silently skipping data.
9. Prefer native Milvus BM25/full-text search for new collections when lexical search is part of the framework:
   - Add an analyzer-enabled text field.
   - Add a `SPARSE_FLOAT_VECTOR` field.
   - Add a `FunctionType.BM25` function.
   - Add `SPARSE_INVERTED_INDEX` for sparse search.
10. Do not silently fall back to local Python BM25 for new Milvus collections unless the project explicitly needs legacy compatibility. A clear error is better than hidden full-scan behavior.
11. Do not call `flush()` after every write. Use collection/read consistency configuration when immediate read-after-write behavior matters.
12. If only some metadata stores can safely pair with Milvus, fail loudly for unsupported combinations instead of silently using a different retrieval path.
13. Build Milvus filter expressions safely: validate field names, escape scalar values, and reject unsupported complex values instead of concatenating raw user input.

## 4. Test the integration

1. Add or extend tests following the project's existing backend/provider patterns.
2. Run focused checks first, then relevant regression suites:
   ```bash
   uv run ruff check <changed paths>
   uv run ruff format --check <changed paths>
   uv run mypy <changed paths>
   uv run pytest <focused test files> -q
   ```
3. For any live remote test that creates collections, clean up temporary collections before finishing.

## 5. Prepare and follow up on the PR

1. Include implementation, tests, docs, examples, dependency metadata, and lockfile updates if the project tracks a lockfile.
2. Check user-facing docs across README quickstarts, detailed docs, examples, config tables, and supported/unsupported combinations.
3. Keep the PR scoped to the current upstream architecture. If an old PR is badly conflicted after upstream refactors, close it with a short note and open a fresh PR from current upstream main/develop.
4. In the PR description, include:
   - What backend was added.
   - Local Milvus Lite behavior.
   - Milvus server / Zilliz Cloud configuration.
   - Test coverage and any known unrelated baseline failures.
5. Do not mention AI, Claude, LLMs, or automatic generation in commit messages, PR title/body, comments, or co-author trailers.
6. After opening the PR, check mergeability and CI. Read automated reviews and maintainer comments; fix valid points, or explain why a suggestion does not apply.
7. If no reviewer is assigned, identify recent human maintainers from merged PRs, `mergedBy`, CODEOWNERS, and external-PR comments before politely mentioning one reviewer.
8. After follow-up fixes, leave a concise English PR comment summarizing what changed and which checks were run.

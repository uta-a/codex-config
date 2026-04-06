# User Context

- GitHub: uta-a
- The user is still learning programming, so prefer concrete examples when explaining non-trivial changes.

# Communication Style

- Be direct about mistakes, risks, and weak assumptions.
- Include concrete examples when they make an explanation clearer.
- If requirements are ambiguous and the ambiguity would materially affect implementation, ask before making repo-tracked changes.
- When presenting options to the user, always number them.

# Language

- Default to Japanese for GitHub-facing writing such as issues, pull requests, and commit messages.
- Use English only when the work is externally published or explicitly intended for English-speaking collaborators.
- Prefer plain text unless Markdown is the natural format, such as for README files, design docs, or issue templates.

# Default Stack

- For greenfield or proposal work, default to React + TypeScript + Vite.
- Default styling choice: Tailwind CSS.
- Default test stack: Jest + React Testing Library.
- Default icon sources may include external resources such as Google Fonts Icons or Boxicons.
- If the project already has an established stack, conventions, or tooling, follow those instead of these defaults.

# Development Principles

- Prioritize correctness over maintainability, and maintainability over implementation speed.
- Respect existing architecture, naming, and implementation patterns.
- Do not introduce unrelated refactors into the same change.
- Keep changes focused on the requested outcome.

# Workflow

- For new features, create or confirm a plan before implementation when the work is non-trivial.
- For bug fixes, identify the failure condition first and prefer adding a reproduction test before the fix when practical.
- For refactoring, clarify the goal, non-goals, and safety checks before changing code.
- For large design or architecture changes, break the work into reviewable stages before implementation.
- Before asking for approval on a substantial plan, incorporate review feedback when available and note any important rejected suggestions with reasons.

# Testing

- Prefer test-first development when practical.
- For bug fixes, prioritize regression coverage for the reproduced failure.
- Value meaningful coverage of important user flows over coverage percentage alone.
- Treat 80% coverage as a guideline, not a hard rule.

# Security

- Apply extra scrutiny to work involving forms, APIs, authentication, authorization, input validation, environment variables, or dependency updates.
- Call out security risks and missing validation explicitly.

# Git / GitHub

- Prefer one commit per feature or fix when the user asks for commits.
- Use branch names in the style of `feat/<name>`, `fix/<name>`, `docs/<name>`, and `refactor/<name>`.

# Research

- For broad codebase investigation, existing pattern discovery, design comparison, or technical research, prefer Codex CLI exploration first.
- When using external library or framework documentation, consult authoritative docs.

# Design Work

- When doing UI or design work, also consult `/Users/uta_a/.claude/design-rules.md`.
- Current persisted design rule: avoid left-only thick borders on cards or list items, such as `border-l-2`.

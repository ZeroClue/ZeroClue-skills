# ZeroClue Skills Kit — Repository Governance

This document defines the standards, processes, and conventions for all skill packs published under the ZeroClue skills kit repository.

## Repository Structure

```
ZeroClue-skills/
├── AGENTS.md                 # This file — repo-level governance
├── .gitignore                # Ignore design docs, validation artifacts
├── skills/                   # Standard container directory (CLI searches here)
│   ├── typescript-expert/    # Pack 1 (self-contained, installable)
│   │   ├── AGENTS.md         # Pack-level skill triggers & precedence
│   │   ├── CLAUDE.md         # Pack summary for Claude Code
│   │   ├── README.md         # Install instructions, skills table
│   │   ├── CHANGELOG.md      # Semantic versioning history
│   │   ├── LICENSE           # MIT
│   │   ├── scripts/validate-pack.sh
│   │   ├── VALIDATION_REPORT.md
│   │   └── typescript-*/     # Six skill directories
│   │       ├── SKILL.md      # agentskills.io spec compliant
│   │       └── references/   # Self-contained reference files
│   └── <future-pack>/        # Additional packs follow same structure
└── docs/                     # Design documents (one per pack, .gitignored)
    └── typescript-expert-design.md
```

## Pack Standards (Non-Negotiable)

Every skill pack in this repo **must** comply with:

### 1. Structure
- Root pack folder named `kebab-case` (e.g., `typescript-expert`)
- Contains: `AGENTS.md`, `CLAUDE.md`, `README.md`, `CHANGELOG.md`, `LICENSE`, `scripts/validate-pack.sh`
- Each skill in its own subdirectory: `<skill-name>/SKILL.md` + `<skill-name>/references/`
- No files outside the skill's own directory tree (self-containment)

### 2. SKILL.md Frontmatter (agentskills.io spec)
```yaml
---
name: <skill-name>           # Must match parent directory exactly
description: <string>        # Non-empty, ≤1024 chars, states what + when to use
metadata:
  version: "1.0.0"
---
```
- `name`: lowercase letters/numbers/hyphens only; no leading/trailing/consecutive hyphens; max 64 chars
- `description`: includes trigger keywords ("Use when...", "For...")

### 3. SKILL.md Anatomy (Required Headings, In Order)
1. `## Overview`
2. `## When to Use`
3. `## Discipline`
   - `### Pre-flight`
   - `### In-flight`
   - `### Post-flight`
4. `## Rationalizations` (table: Excuse | Rebuttal)
5. `## Red Flags`
6. `## Verification` (computational gates, evidence-based)
7. `## References` (paths relative to skill's own `references/`)

### 4. Token Budgets
- SKILL.md body: ≤6,000 chars (~1,500 tokens)
- Description: ≤1,024 chars
- Reference files: no strict limit but stay focused

### 5. Cache Stability
- **No dates** in SKILL.md bodies
- **No "latest"** in SKILL.md bodies
- **No version pins** (e.g., "TypeScript 5") in SKILL.md bodies
- Version-specific guidance belongs in exactly ONE reference file per skill

### 6. Cross-Skill References
- Reference sibling skills by name only: `typescript-boundaries`
- Never by filesystem path
- Tools/libraries (e.g., `typescript-eslint`, `zod`) are not skills — no warning suppression needed

### 7. Code Blocks
- All fenced blocks carry language tags (`typescript`, `json`, `bash`, etc.)
- Complete examples must be syntactically valid
- Partial fragments must have balanced braces/parentheses

### 8. Style
- No em-dashes (use `--` or commas)
- Fenced code blocks have language tags
- Tables use pipes and hyphens

## Pack Creation Process (4 Phases)

### Phase 0 — Verify Inputs
- Read design document completely
- Confirm all skills, reference files, root docs present with substantive content
- **STOP if anything missing** — do not invent

### Phase 1 — Materialize
- Create exact tree structure
- Transcribe design content verbatim (no rewriting, rephrasing, reordering)
- Only permitted changes: typo fixes, syntax errors in code blocks, markdown for rendering
- `git init` and commit if git available

### Phase 2 — Validate
- Write `scripts/validate-pack.sh` that checks:
  - a. Every expected file exists; no unexpected files
  - b. Frontmatter: `name` = directory; pattern; length; `description` present, ≤1024, non-empty
  - c. All 7 anatomy headings present in order
  - d. All referenced files exist in skill's own `references/`
  - e. Cross-skill mentions name existing sibling skills
  - f. SKILL.md body ≤6,000 chars
  - g. No forbidden content (dates, "latest", version pins)
  - h. All fenced code blocks open/close with language tags
- Run → fix every failure → re-run until exit 0
- Commit

### Phase 3 — Code Sample Audit
- Review every TypeScript code block in the pack
- Complete examples: syntactically valid TypeScript
- Intentional fragments (`...`, pseudo-code): balanced braces/parentheses minimum
- Fix real syntax errors without changing meaning
- Do not redesign examples

### Phase 4 — Report
Produce `VALIDATION_REPORT.md` with:
- File count vs. expected
- Token/char count per SKILL.md
- Validation script output (clean run)
- Deviations from design (expected: zero, or typo fixes only)
- Design observations noted but not acted on

## Validation Script Requirements

Every pack must include `scripts/validate-pack.sh` that:
- Exits 0 on clean pass, non-zero on any error
- Checks all 8 criteria above
- Outputs clear PASS/FAIL per check
- Is executable (`chmod +x`)

## Versioning & Release

- Pack version in `metadata.version` (semantic)
- `CHANGELOG.md` follows Keep a Changelog
- Tag releases: `<pack-name>@v<version>` (e.g., `typescript-expert@v1.0.0`)
- skills.sh install uses GitHub repo + tag

## Cross-Pack Conventions

| Aspect | Rule |
|--------|------|
| Precedence | Defined in pack's `AGENTS.md`; more specific skill wins; conflicts → ask user |
| Composition | Language discipline packs (this repo) own judgment; process packs own workflow; conflicts → surface to user |
| Self-containment | Each skill installs independently; no shared references across packs |
| Naming | Pack: `kebab-case`; Skill: same as pack subdirectory |

## Adding a New Pack

1. Create design doc in `docs/<pack-name>-design.md`
2. Follow Phase 0–4 process exactly
3. Run validation script to clean pass
4. Add entry to this AGENTS.md "Published Packs" section below
5. Tag and publish

## Published Packs

| Pack | Version | Description |
|------|---------|-------------|
| `typescript-expert` | 1.0.0 | Production TypeScript discipline — 6 composable skills |

---

*This governance document applies to all skill packs in the ZeroClue skills kit. Pack-level AGENTS.md files define skill triggers and precedence within their pack.*
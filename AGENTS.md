# ZeroClue Skills Kit — Repository Governance

This document defines the standards, processes, and conventions for all skills published under the ZeroClue skills kit repository.

## Repository Structure

```
ZeroClue-skills/
├── AGENTS.md                 # This file: repo-level governance
├── README.md                 # Public pack index + install instructions
├── CONTRIBUTING.md           # PR checklist, modification rules
├── .gitignore
├── scripts/
│   └── validate-pack.sh      # Parameterized authoring-time validator
├── skills/                   # Public packs and standalone skills
│   └── typescript-expert/    # Pack: 6 skills, one baseline
│       ├── AGENTS.md         # Pack-level triggers & precedence
│       ├── CLAUDE.md         # Pack summary for Claude Code
│       ├── README.md         # Pack install instructions
│       ├── CHANGELOG.md      # Per-pack release history
│       ├── DECISIONS.md      # Public design decision record
│       ├── evals/            # At least one eval per skill
│       └── typescript-*/     # Each skill: SKILL.md + references/
├── .agents/                  # Internal skills (gitignored, not published)
└── docs/                     # Private working docs (gitignored)
```

## Skill Units

Two first-class unit types live under `skills/`:

| Unit | Definition | When warranted |
|---|---|---|
| **Pack** | 3 to 7 skills covering one domain: one always-firing baseline plus siblings that add depth on specific triggers | The domain has a baseline plus distinct trigger domains needing separate treatment |
| **Standalone skill** | One skill directory (`SKILL.md` + `references/` + `evals/`) | The domain does not warrant routing depth; one skill covers it |

The pack-vs-standalone decision is made at design time and recorded in the pack's `DECISIONS.md`. More than 7 skills means the domain is two packs; fewer than 3 usually means one standalone skill.

Requests spanning multiple trigger domains fire multiple skills simultaneously: the baseline co-fires with every sibling whose trigger matches, and precedence rules resolve rule conflicts between co-fired skills — never firing exclusivity.

## Pack Standards (Non-Negotiable)

Every skill unit in this repo **must** comply with:

### 1. Structure
- Multi-skill pack root: `AGENTS.md`, `CLAUDE.md`, `README.md`, `CHANGELOG.md`, `DECISIONS.md`, `evals/`, plus one directory per skill
- Standalone skill: `SKILL.md`, `references/`, `evals/`
- Each skill in its own subdirectory: `<skill-name>/SKILL.md` + `<skill-name>/references/`
- Self-containment: references live inside the skill's own directory; no path may point outside the skill; cross-skill references by skill NAME only (per-skill installers copy single skills)

### 2. SKILL.md Frontmatter (agentskills.io spec)
```yaml
---
name: <skill-name>           # Must match parent directory exactly
description: <string>        # Non-empty, ≤1024 chars, states what + when to use
metadata:
  version: "1.0.0"           # Per skill, not per pack
---
```
- `name`: lowercase letters/numbers/hyphens only; no leading/trailing/consecutive hyphens; max 64 chars
- `description`: includes trigger keywords using the domain's actual vocabulary

### 3. Anatomy (two types, selected by pack kind)
**Discipline anatomy** (coding-rule packs — rules for writing code):
1. `## Overview`
2. `## When to Use`
3. `## Discipline` with `### Pre-flight` / `### In-flight` / `### Post-flight`
4. `## Rationalizations` (table: Excuse | Rebuttal)
5. `## Red Flags`
6. `## Verification` (computational gates, evidence-based)
7. `## References`

**Process anatomy** (workflow packs — phases for producing artifacts):
1. `## Overview`
2. `## When to Use`
3. `## Process` (numbered phases, each with an exit gate)
4. `## Rationalizations`
5. `## Red Flags`
6. `## Verification`
7. `## References`

Selection rule: rules that govern writing code → Discipline; workflow that produces artifacts → Process.

### 4. Budgets
- SKILL.md body: ≤6,000 chars (~1,500 tokens)
- Description: ≤1,024 chars (~60 words)
- References: one concern per file; loaded on demand; as short as the concern allows

### 5. Cache Stability
- **No dates** in SKILL.md bodies
- **No "latest" claims** in SKILL.md bodies
- **No version pins** (e.g., "TypeScript 5") in SKILL.md bodies
- Version-specific guidance lives in exactly one reference file per skill

### 6. Cross-Skill References
- Reference sibling skills by name only: `typescript-boundaries`
- Never by filesystem path
- Tools/libraries (e.g., `typescript-eslint`, `zod`) are not skills

### 7. Code Blocks
- All fenced blocks carry language tags (`typescript`, `json`, `bash`, etc.)
- Complete examples must be syntactically valid
- Partial fragments must have balanced braces/parentheses

### 8. Style
- No em-dashes (use `--` or commas)
- Fenced code blocks have language tags
- Tables use pipes and hyphens

### 9. Evals
- `evals/` directory at the pack root (packs) or skill root (standalone)
- **At least one eval file per skill**; a pack must have eval count ≥ skill count
- Eval file structure (required sections): `# eval:` title, `## Scenario`, `## Expected routing`, `## Expected behavior`, `## What verification must catch`, `## Pass criteria`
- `## Expected routing` must name the COMPLETE firing set: every skill that fires (baseline co-fires) and every skill that must not
- Minimum set per pack: baseline trigger, sibling trigger, anti-trigger (a neighboring-domain task that must NOT fire the pack), rationalization probe
- Evals are design artifacts: update them when the design changes; treat an eval you cannot keep green as a design smell
- Running evals is manual (fresh session, with/without diff); structural validity is checked by the validator

### 10. Decision Records
- Every public unit commits a `DECISIONS.md`: shape, anatomy, routing, key decisions with alternatives, verification approach, rationalization sources, source-citation status
- Full design docs (verbatim grill answers, user conversation) stay private in `docs/`
- `DECISIONS.md` is the contributor-facing contract; the design doc is the private source of truth

## Pack Creation Process (7 Phases)

Packs and standalone skills are built via the skillpack-engineering process. Each phase has an exit gate; do not advance until the gate passes.

1. **Grill** — interview the user, ONE question at a time. Extract: domain and scope, out-of-scope, target harnesses, known agent failure modes (verbatim — they become rationalization tables), trusted sources, deployment shape (pack vs standalone), verification tooling. Output: a glossary that becomes trigger keywords.
2. **Research** — extract rules, patterns, anti-patterns, and verification commands from grill-approved sources. Cite each rule to its source; flag anything ungrounded as UNVERIFIED. Knowledge-only path ships UNVERIFIED with user approval.
3. **Design** — apply the pack template: skills, anatomy per kind, budgets, trigger-distinct descriptions, computational verification gates, self-containment, cache stability. Output: one design doc plus decision records.
4. **Review gate** — present the design to the user; list every decision and its alternatives. STOP. Do not build until explicitly approved. This gate is mandatory; skipping it converts engineering into generation.
5. **Build** — faithful transcription of the approved design plus validation. Never redesign. Use the build prompt contract (paste-able standalone where the skill is not installed).
6. **Verify** — validation exits 0; evals authored per the minimum set; description trigger-distinctness checked (no sibling pair shares a trigger phrase); dogfood the pack's own verification logic on its samples.
7. **Register** — add to the repo index (root README), record per-skill versions, archive the design doc in `docs/`, note refinements for the process.

## Validation

One parameterized authoring-time validator at the repo root:

```bash
scripts/validate-pack.sh skills/typescript-expert
scripts/validate-pack.sh .agents/skills/<internal-skill>
```

It handles both shapes (multi-skill pack; single-skill pack) and infers anatomy from the `## Discipline` / `## Process` section. It checks: expected files, frontmatter (name/description/rules), anatomy headings in order, references exist in the skill's own directory, self-containment (no escaping paths), body budgets, cache stability, balanced/language-tagged fences, eval presence + structure, and sibling-description overlap (routing distinctness heuristic).

Packs themselves carry **no dependency** on the validator; they remain self-contained for per-skill installs. Domain-specific mention heuristics may be added as pack-local checks when warranted.

## Internal Skills

Private/internal skills live in `.agents/skills/` (gitignored):
- They follow the same standards as public skills, including evals
- They are not listed in the public index (README) and are invisible to skills.sh
- They are tools for building and maintaining this repo, not distribution artifacts
- Publication = move to `skills/`, add `DECISIONS.md`, un-ignore, register in the index

## Versioning & Release

- Version in each skill's `metadata.version` (semantic, per skill not per pack)
- `CHANGELOG.md` per pack, following Keep a Changelog
- Tag releases: `<pack-name>@v<version>` (e.g., `typescript-expert@v1.0.0`)

## Cross-Pack Conventions

| Aspect | Rule |
|--------|------|
| Precedence | Defined in pack's `AGENTS.md`; more specific skill wins; conflicts → ask user |
| Composition | Domain packs own judgment; process packs (spec-driven development, TDD, review) own workflow; conflicts → surface to user |
| Self-containment | Each skill installs independently; no shared references across packs |
| Naming | Pack and standalone: `kebab-case`; skill: same as its directory |

## Adding a New Pack or Standalone Skill

1. Grill the domain (scope, out-of-scope, failure modes, sources, shape, tooling)
2. Design; run the design checklist; zero unexplained deviations
3. Review gate: present design, stop for explicit approval
4. Build via faithful transcription; validate to exit 0
5. Author evals (minimum set + probes); verify routing distinctness
6. Add `DECISIONS.md`; update the repo index; commit design doc to private `docs/`
7. Tag and publish

## Published Units

| Unit | Type | Version | Description |
|------|------|---------|-------------|
| `typescript-expert` | Pack | 1.0.0 | Production TypeScript discipline — 6 composable skills, baseline `typescript-core` |

---

*This governance document applies to all skills in the ZeroClue skills kit. Pack-level AGENTS.md files define skill triggers and precedence within their pack. Internal skills follow the same standards; they are simply not distributed.*
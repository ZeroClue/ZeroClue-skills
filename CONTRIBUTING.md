# Contributing

Units in this repo (packs and standalone skills) are built via a seven-phase
process: grill, research, design, review gate, build, verify, register. This
document is the public authoring standard. The parameterized validator
enforces it: run `scripts/validate-pack.sh <pack-dir>`, fix until green.

## Unit standards

### Frontmatter (agentskills.io spec, per SKILL.md)
```yaml
---
name: <skill-name>           # Must match parent directory exactly
description: <string>        # Non-empty, ≤1024 chars, states what + when
metadata:
  version: "1.0.0"           # Per skill, not per pack
---
```
- `name`: lowercase letters, numbers, hyphens; no leading/trailing/consecutive
  hyphens; max 64 chars
- `description`: trigger keywords in the domain's actual vocabulary; no two
  siblings may claim the same trigger

### Anatomy (two types, by pack kind)
**Discipline** (coding-rule packs): Overview, When to Use, Discipline with
Pre-flight / In-flight / Post-flight, Rationalizations (excuse | rebuttal
table, built verbatim from observed agent failure modes), Red Flags,
Verification (computational gates), References.

**Process** (workflow packs): Overview, When to Use, Process (numbered phases,
each with an exit gate), Rationalizations, Red Flags, Verification,
References.

### Budgets
- SKILL.md body: ≤6,000 chars (~1,500 tokens)
- Description: ≤1,024 chars (~60 words)
- References: one concern per file, loaded on demand

### Cache stability (SKILL.md bodies)
No dates, no recency claims, no version pins. Version-specific guidance lives
in exactly one reference file per skill.

### Self-containment
References live inside each skill's own directory; no path escapes the skill;
cross-skill references by name only. Packs carry no dependency on the repo
validator.

### Code blocks and style
All fenced blocks carry language tags; complete examples are syntactically
valid; fragments have balanced delimiters. No em-dashes.

## Evals

- `evals/` at the pack root (or skill root, standalone); at least one eval
  file per skill
- File format: see any file in `skills/typescript-expert/evals/` — first line
  `# eval: <short-name>`, then Scenario, Expected routing (the complete
  firing set: baseline co-fires; name what must NOT fire), Expected
  behavior, What verification must catch, Pass criteria
- Minimum set per pack: baseline trigger, sibling trigger, anti-trigger
  (neighboring domain must NOT fire the pack), rationalization probe
- Running evals is manual: fresh session, scenario pasted without pack
  context; strongest form is the with/without-pack diff

## Adding a unit

1. Grill the domain: scope, out-of-scope, target harnesses, agent failure
   modes (recorded verbatim), trusted sources, pack-vs-standalone shape,
   verification tooling
2. Design; run the design checklist; zero unexplained deviations
3. Review gate: present the design to the maintainers and stop for explicit
   approval — no building before approval
4. Build by faithful transcription of the approved design; no redesign
5. Author evals; verify routing distinctness; validate to green
6. Add `DECISIONS.md` (shape, anatomy, routing, key decisions with
   alternatives, source-citation status); update the root README index

## PR checklist

- [ ] `scripts/validate-pack.sh <pack-dir>` exits 0
- [ ] At least one eval per skill, structured per the format
- [ ] `DECISIONS.md` added or updated
- [ ] No shared root `references/` (self-containment)
- [ ] Version bumped per changed skill (`metadata.version`)
- [ ] SKILL.md bodies cache-stable

## Modifying an existing pack

Run the pack's evals before and after your change. A red eval after a green
one means the change regressed routing or a rule: fix the change, or update
the eval with a decision-record note in `DECISIONS.md` saying why.
# ZeroClue Skills Kit

Agent skill packs and standalone skills, built to the agentskills.io spec.
Every skill is self-contained and installable alone.

## Structure

```
ZeroClue-skills/
├── AGENTS.md            # This file: routing and conventions
├── README.md            # Public unit index + install
├── CONTRIBUTING.md      # Authoring standards (lazy: read when contributing)
├── scripts/validate-pack.sh   # Parameterized authoring-time validator
├── skills/              # Public packs and standalone skills
│   └── typescript-expert/     # Pack: 6 skills, baseline typescript-core
└── .agents/skills/      # Internal skills (gitignored, not distributed)
```

## Units

| Unit | Type | Location |
|------|------|----------|
| typescript-expert | Pack (6 skills, baseline `typescript-core`) | `skills/typescript-expert/` |

Two unit types: **packs** (3 to 7 skills, one always-firing baseline plus
trigger-routed siblings) and **standalone skills** (one skill, warranted when
a domain needs no routing depth). Choice is made at design time and recorded
in the unit's `DECISIONS.md`.

## Conventions

- Requests spanning multiple trigger domains fire multiple skills; precedence
  lives in each pack's `AGENTS.md` and resolves rule conflicts, never firing
  exclusivity.
- Domain packs own judgment; process packs own workflow. Conflicts surface to
  the user, never silently resolved.
- Self-containment: references live inside each skill; cross-skill references
  by name only.
- Versioning: per-skill `metadata.version`; `CHANGELOG.md` per pack.

## Guardrail

Skill files in this repo are governed artifacts. Do not casually edit
SKILL.mds, descriptions, or evals; changes go through the evals-before-and-
after rule in `CONTRIBUTING.md`.

## Pointers (lazy: load on demand)

- **Authoring standards** (anatomy, budgets, cache stability, evals format,
  process): `CONTRIBUTING.md`
- **Deep authoring process**: the `skillpack-engineering` skill (internal,
  `.agents/skills/`)
- **Enforcement**: `scripts/validate-pack.sh <pack-dir>` — the validator is
  the spec; run it, fix until green
- **Per-pack rationale**: each unit's `DECISIONS.md`
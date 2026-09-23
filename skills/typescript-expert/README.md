# typescript-expert

Production TypeScript discipline for coding agents. Six composable skills, one baseline.

## Install

**Option A — skills.sh (recommended)**
```bash
npx skills@latest add ZeroClue/ZeroClue-skills
```
The installer discovers the `typescript-expert` pack under `skills/` and lets you pick skills and target agent — works for Claude Code, Cursor, Codex, opencode, Pi, and others.

**Option B — Manual copy**
Drop the `skills/typescript-expert` folder into your agent's skills directory:
- Claude Code: `.claude/skills/`
- Cursor: `.cursor/skills/` (also reads `.claude/skills/`)
- Codex: repo root `skills/`
- opencode: `.opencode/skills/`
- Pi: project-local skills dir or `~/.pi/agent/skills/`

**Option C — Paste into a session**
Paste any single `SKILL.md` body directly as instructions; each is self-contained.

## Skills and Triggers

| Skill | Fires when |
|-------|------------|
| typescript-core | Any `.ts`/`.tsx` write, edit, review, or tsconfig change. The always-on baseline. |
| typescript-type-level | Complex generics, conditional/`infer`/mapped types, variance, overloads, library/DSL type design. |
| typescript-boundaries | fetch/HTTP, JSON.parse, request bodies, env vars, forms, localStorage, external API data — any untrusted input. |
| typescript-async | async/await, Promises, retries, timeouts, cancellation, concurrency, error handling. |
| typescript-architecture | Project setup, tsconfig strategy, monorepos, module boundaries, public API surface. |
| typescript-migration | JS→TS conversion, enabling strict flags, TS upgrades, suppression burn-down. |

## Precedence

1. `typescript-migration` overrides the core strict baseline while a migration is active (it defines when the override ends).
2. `typescript-boundaries`, `typescript-async`, `typescript-type-level`, `typescript-architecture` add depth to their trigger domains; they never contradict `typescript-core`.
3. If two rules conflict, the more specific skill wins; if still unclear, stop and ask the user.

## Composition with Other Packs

This pack is a language discipline layer. Process packs (spec-driven development, TDD loops, code review) own workflow; this pack owns TypeScript judgment. If a process skill and this pack ever disagree, surface the conflict to the user rather than silently picking one.
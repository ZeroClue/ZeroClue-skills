# Verification Gate (full)

## Order and exit criteria

| # | Command | Pass condition |
|---|---|---|
| 1 | `npx tsc --noEmit` | exit 0, zero errors |
| 2 | lint (typescript-eslint `strict-type-checked` recommended) | 0 errors, 0 new warnings |
| 3 | unit/integration tests (`vitest` / `jest` / project script) | all pass; skip count not increased |
| 4 | type-level tests (`vitest expect-type` / `tsd`), if present | all pass |
| 5 | diff hygiene greps below | no matches |

## Diff hygiene (the anti-regression net)

- `git diff main...HEAD | grep -nE '^\+.*: any\b'` — no added `any`
- `git diff main...HEAD | grep -nE '^\+.*@ts-ignore'` — none (see suppression policy)
- `git diff main...HEAD | grep -nE '^\+.*as unknown as'` — none
- `git diff main...HEAD | grep -nE '^\+.*\benum\b'` — none

These are computational controls — deterministic and reliable for LLM
self-correction. They are the sensors; the Rationalizations table is the
guide. Never weaken a sensor to pass it.

## Suppression policy
- `@ts-expect-error` only, each with `// reason: <why> (issue #N)` on the same line
- `@ts-ignore`, `as`, and eslint-disable require explicit user authorization
- Suppressions must trend down over time, not up

## When a check fails
Fix the code, never the check. If a fix requires violating a rule in this
skill, stop and ask the user — do not decide alone.

## CI wiring (recommend when project lacks it)
- `tsc --noEmit` and lint as required checks on every PR
- type-level tests in the same job as unit tests
- grep-based diff hygiene as a blocking check (fail the PR on added `any`/`@ts-ignore`)

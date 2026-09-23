---
name: typescript-core
description: Production TypeScript discipline for every file write — strict compiler
  baseline, inference over annotation, satisfies over casts, literal unions over
  enums, unknown at boundaries. Use when writing, modifying, or reviewing any
  TypeScript file, or touching tsconfig.json.
metadata:
  version: "1.0.0"
---

# TypeScript Core Discipline

## Overview
Baseline rules for every line of TypeScript. This is the always-on layer of the
typescript-expert pack; siblings (type-level, boundaries, async, architecture,
migration) add depth when their triggers fire.

## When to Use
- Writing or editing any `.ts` / `.tsx` file
- Reviewing or refactoring TypeScript
- Touching `tsconfig.json` or package config
- Any TypeScript question that lacks a more specific trigger

## Discipline

### Pre-flight (before writing code)
1. Check the compiler baseline. If `strict` is off and this is not an active
   migration, STOP and propose the strict baseline first
   (see references/tsconfig-baseline.md). Mid-migration codebases: defer to
   the typescript-migration skill.
2. Confirm runtime targets: `moduleResolution: "NodeNext"` for Node,
   `"Bundler"` for bundlers. Target `ES2022` or later.

### In-flight (while writing)
Ordered by frequency of application:
- Let inference work. No annotation where the initializer determines the type.
- Model the domain: literal-union states, `Record<string, T>` for keyed maps,
  named tuples `[id: string, age: number]` for positional data.
- Literal unions and `as const` objects. Never `enum`.
- `import type` for every type-only import.
- `unknown` at boundaries; narrow before use (depth: typescript-boundaries).
- `satisfies` over `as`. `as unknown as T` is a bug, not a technique.
- `?.` and `??`; never `||` for string defaults, never ternary ladders.
- `async/await` in `try/catch`; no floating promises; no new `.then` chains.
- `const` by default; rest-destructure instead of `delete`.
- State machines as discriminated unions; exhaustive switches with the
  `never` check in `default`.

### Post-flight (before declaring done)
Run the Verification gate below. It is not optional and has no judgment calls.

## Rationalizations

| Excuse | Rebuttal |
|---|---|
| "any is faster here" | `unknown` costs one narrowing check; `any` disables checking for the entire downstream call graph. |
| "I know the shape, `as` is safe" | If you know it, `satisfies` compiles. If it doesn't compile, you didn't know it. |
| "@ts-ignore, just temporary" | Use `@ts-expect-error` with a reason and issue link. `ignore` hides future errors silently; `expect-error` fails once the error is fixed. |
| "An enum is clearer here" | Literal unions are erased, tree-shake, and never have nominal-identity surprises. `as const` objects cover the few cases needing runtime values. |
| "The type is too complex" | That's the type-level skill's trigger, not a license to widen to `object` or `Record<string, any>`. |
| "I'll add tests after" | The verification gate includes tests now. Green-without-tests is red. |
| "`||` works fine" | It also fires on `""` and `0`. `??` is what you meant. |
| "Disabling this rule just this once" | Never without explicit user authorization. Silencing sensors is the canonical agent failure mode. |

## Red Flags
Stop and reassess if the diff:
- introduces `any`, an `as` cast, `@ts-ignore`, or a new `enum`
- uses `||` to default a nullable string
- widens a type (`object`, `Record<string, any>`, `unknown` returned without narrowing) to make an error disappear
- deletes or skips tests to get a green run

## Verification
Run all, in order. Exit criteria are computational, not judgment:
1. `npx tsc --noEmit` — exit code 0
2. Project lint (prefer typescript-eslint `strict-type-checked`) — zero errors,
   zero new warnings
3. Diff hygiene: `git diff main...HEAD | grep -nE '^\+.*(@ts-ignore|: any\b|as unknown as)'`
   — no matches
4. Project test runner — all pass, skipped count not increased vs. main

Evidence means pasted command output. "It compiles" without pasted `tsc`
output is a claim, not evidence. Full gate: references/verification.md

## References
- references/tsconfig-baseline.md — strict config with per-flag rationale
- references/patterns.md — expanded pattern library with examples
- references/verification.md — full gate incl. type-level tests and CI wiring

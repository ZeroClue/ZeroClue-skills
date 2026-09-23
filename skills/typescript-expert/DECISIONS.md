# typescript-expert — Decision Record

Public record of the design decisions behind this pack. Full design
documentation is private. Alternatives are recorded where meaningful.

## Shape

- Pack of 6 skills: `typescript-core` is the always-on baseline; five
  siblings add depth on specific triggers.
- Alternative rejected: one monolithic skill (wastes context on every fire;
  no routing). Proficiency tiers (basic/intermediate/advanced) also
  rejected: agents route on triggers, not self-assessed seniority; tiers
  imply optionality, triggers imply defaults.
- Requests spanning multiple trigger domains fire multiple skills
  simultaneously; the baseline co-fires with every sibling whose trigger
  matches. Precedence resolves rule conflicts, never firing exclusivity.

## Anatomy

- All six skills use the Discipline anatomy (coding-rule pack):
  Pre-flight / In-flight / Post-flight. Rationalization tables
  (excuse | rebuttal) are the highest-value content, built from observed
  agent failure modes recorded verbatim.

## Routing

- Trigger-based per the table in `AGENTS.md`. Distinct trigger phrases per
  skill; descriptions double as the routing layer.
- `typescript-migration` overrides the core strict baseline while a
  migration is active and defines its own exit condition. Siblings never
  contradict core. Rule conflicts: more specific skill wins; still unclear,
  ask the user.
- Composition: this pack is a language discipline layer. Process packs
  (spec-driven development, TDD loops, code review) own workflow; this pack
  owns TypeScript judgment. Conflicts are surfaced to the user, never
  silently resolved.

## Key domain decisions

- Strict compiler baseline: `strict`, `noUncheckedIndexedAccess`,
  `exactOptionalPropertyTypes`, `noImplicitOverride`,
  `noFallthroughCasesInSwitch`, `isolatedModules`,
  `moduleDetection: "force"`, `verbatimModuleSyntax`. NodeNext for Node,
  Bundler for bundlers, target ES2022 or later.
- `satisfies` over `as`; `as unknown as T` banned outside documented
  migration seams.
- Literal unions plus `as const`; `enum` banned.
- `import type` for every type-only import; inference over annotation where
  the initializer determines the type.
- `unknown` at boundaries; parse-don't-validate with schema libraries
  (Zod/valibot/standard-schema named, none mandated); branded IDs parsed at
  the edge; env parsed once at startup.
- Result type for expected async failures; throw reserved for bugs;
  AbortSignal threaded from caller; bounded concurrency; capped retries with
  backoff and jitter, never on 4xx.
- tsconfig.base.json plus project references for monorepos; export
  minimalism (Hyrum's Law); explicit return types on public functions; no
  barrel files; no cycles.
- JS-to-TS leaf-first with `allowJs` bridge; strict rollout order
  (strictNullChecks first, then noImplicitAny, then the family);
  `@ts-expect-error` only, each with reason and issue link, on a tracked
  burn-down budget.

## Verification

- Computational gates only: `tsc --noEmit`, typescript-eslint
  `strict-type-checked`, project test runner, diff-hygiene greps
  (`@ts-ignore`, `: any`, `as unknown as`, `enum` in added lines).
- Evidence means pasted command output; "it compiles" without pasted `tsc`
  output is a claim, not evidence.

## Rationalization sources

- Built from observed agent failure modes (verbatim excuses):
  as-casts justified by "I know the shape", `any` for speed, `@ts-ignore`
  as temporary, enum apologetics, `||` defaults, floating promises,
  validation deferral, big-bang migrations, suppression cleanup deferral.

## Source status

- Rules were synthesized at design time from TypeScript ecosystem
  conventions and practitioner practice. Formal per-rule source citations
  were not backfilled for 1.0.0 (grandfathered; the source protocol postdates
  this pack). Backfilling citations is optional future hardening; new units
  in this repo must cite sources per governance.

## Alternatives considered

- Per-skill installation: supported; every skill is self-contained
  (references inside each skill, cross-references by name only).
- Schema library mandate: rejected; Zod, valibot, and standard-schema
  implementations are all acceptable.
- Standalone (single-skill) shape: rejected for this domain; the baseline
  plus five trigger domains warranted a pack.
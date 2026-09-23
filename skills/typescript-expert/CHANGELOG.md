# Changelog

All notable changes to the typescript-expert skills pack will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `evals/`: 13 eval files per the repo eval standard (7 routing evals covering
  each skill's trigger plus an anti-trigger; 6 rationalization probes, one per
  skill). Routing evals assert complete firing sets (baseline co-fires).
- `DECISIONS.md`: public design decision record.

### Removed
- Pack-local `scripts/validate-pack.sh`: validation moved to the repo-root
  parameterized validator (`scripts/validate-pack.sh <pack-dir>`). Packs carry
  no dependency on the validator and stay self-contained for per-skill installs.

### Fixed
- `typescript-architecture/references/module-design.md`: two bare code fences
  (file tree, layering rules) tagged `text` per the language-tag standard.

## [1.0.0] - 2026-09-22

### Added
- **typescript-core**: Baseline TypeScript discipline — strict config, inference over annotation, `satisfies` over `as`, literal unions, `unknown` at boundaries, verification gate
- **typescript-type-level**: Advanced type construction — conditional types, `infer`, mapped types, template literals, variance, branded types; simplicity gate for when NOT to use advanced types
- **typescript-boundaries**: Untrusted input handling — `unknown` at the edge, parse-don't-validate, schema validation (Zod/valibot), branded IDs, env parsing
- **typescript-async**: Async discipline — try/catch around await, no floating promises, Result pattern for expected errors, AbortController cancellation, timeouts, structured concurrency, retry with backoff
- **typescript-architecture**: Project-level architecture — tsconfig base-config pattern, monorepo project references, module boundaries, import direction, public API surface minimalism, Hyrum's Law
- **typescript-migration**: Incremental adoption — JS→TS leaf-first conversion, strict flag rollout order, TS version upgrades, suppression burn-down with `@ts-expect-error` budget
- **scripts/validate-pack.sh**: Validation script checking structure, frontmatter, anatomy, references, cross-refs, token budgets, cache stability, code block balance
- **README.md**: Install instructions (skills.sh + manual per agent), skills/trigger table, precedence, composition
- **AGENTS.md** / **CLAUDE.md**: Pack metadata for agent runners
- **LICENSE**: MIT license

### Notes
- Each skill is self-contained with its own `references/` directory
- Skills compose: `typescript-core` is always-on; others fire on their trigger domains
- `typescript-migration` temporarily overrides core strictness under a written plan with exit condition
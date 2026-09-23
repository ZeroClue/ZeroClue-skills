# Incremental Strategies

## Strict flag rollout order

| Order | Flag | Why this position |
|---|---|---|
| 1 | `strictNullChecks` | Largest error class, highest value (most real bugs), and later flags assume it. |
| 2 | `noImplicitAny` | Second-largest class; usually mechanical fixes once null is handled. |
| 3 | rest of `strict: true` | Family flags; mostly small once the big two are clean. |
| 4 | `noUncheckedIndexedAccess` | Distinct error class (indexing); enable after core is stable. |
| 5 | `exactOptionalPropertyTypes` | Fiddliest; enable when the team is ready for the polish pass. |

## JS→TS conversion: leaf-first

1. `allowJs: true` in tsconfig — both live together during the migration.
2. Order files by importer count, ascending (leaf = fewest importers of its types).
3. Per file: rename to `.ts`, fix errors, run the full core gate, commit.
4. Optionally pre-stage with `// @ts-check` + JSDoc annotations on the `.js` file — surfaces errors before the rename makes them blocking.

## Why leaf-first
Converting a leaf changes only its own file's errors. Converting a root module first invalidates every importer's types simultaneously — a fan-out of errors that cascades until every file is done. Leaf-first keeps each step local.

## Version upgrades
- Read the release's breaking changes list first (typescriptlang.org/docs, "What's New" per release).
- Upgrade, run `tsc --noEmit`, fix what the compiler names — the error messages are the changelog in practice.
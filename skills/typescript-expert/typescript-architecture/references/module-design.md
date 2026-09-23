# Module Design

## Base-config pattern

```text
repo/
├── tsconfig.base.json      # strictness, shared flags, rationale comments
├── packages/
│   ├── core/
│   │   ├── tsconfig.json  # extends base, adds only deltas
│   │   └── src/
│   └── app/
│       ├── tsconfig.json   # extends base, adds DOM lib, bundler resolution
│       └── src/
```

```jsonc
// tsconfig.base.json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "verbatimModuleSyntax": true
    // why-comments for any deviation live on the deviating package
  }
}
```

## Project references (monorepo)

```jsonc
// packages/app/tsconfig.json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": { "composite": true, "rootDir": "src" },
  "references": [{ "path": "../core" }]
}
```
Build with `tsc -b`: TS builds the graph in dependency order; a type error in core fails app's build, not its runtime.

## Layering rules

```text
entry points (main, routes)   → may import: services, domain
services                      → may import: domain, primitives
domain                        → may import: primitives
primitives (types, utils)     → imports: nothing project-internal
```
Dependency arrows point down. An import that points up is the bug — extract the shared piece downward.

## Import hygiene
- No `../../..` crossing a package/layer boundary
- Path aliases (via `paths`) are for boundary crossings within a layer, not a shortcut for bad structure
# tsconfig Baseline

## The config

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "noFallthroughCasesInSwitch": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "verbatimModuleSyntax": true,
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext"
  }
}
```

For bundler-based projects (Vite, esbuild, most app frameworks): replace the
module trio with `"module": "ESNext"`, `"moduleResolution": "Bundler"`. Everything
else stays.

## Per-flag rationale

| Flag | Why |
|---|---|
| `strict: true` | Enables the strict family: `noImplicitAny`, `strictNullChecks`, `strictFunctionTypes`, `strictBindCallApply`, `strictPropertyInitialization`, `alwaysStrict`, `useUnknownInCatchVariables`. Non-negotiable floor. |
| `noUncheckedIndexedAccess` | `arr[i]` is `T \| undefined`, because it is. Indexing is a boundary; treat it like one. |
| `exactOptionalPropertyTypes` | Distinguishes "absent" from "present but undefined". Removes a whole class of `?? undefined` bugs. |
| `noImplicitOverride` | Forces `override` on subclass members, so base-class renames become compile errors, not silent orphans. |
| `noFallthroughCasesInSwitch` | Non-cases in state machines must be explicit `break`/`return`. Pairs with the exhaustiveness check. |
| `isolatedModules` | Every file must be transpilable alone. Bans re-exported type-only values without `export type`. Required for esbuild/swc correctness. |
| `moduleDetection: "force"` | Every file is its own module. Kills the global-script leak-through class of bugs. |
| `verbatimModuleSyntax` | Enforces `import type` mechanically: type-only imports that aren't marked are errors. The compiler-enforced version of the `import type` rule. |

## When proposing changes
- Add the rationale as a `// why:` comment next to any non-default flag.
- If the project must deviate (legacy build tools), document the constraint and
  the exit condition; deviation is debt, not preference.

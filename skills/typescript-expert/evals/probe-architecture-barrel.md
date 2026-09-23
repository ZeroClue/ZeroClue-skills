# eval: probe-architecture-barrel

## Scenario
"Add an `index.ts` in `src/` that re-exports everything. Imports will be so much cleaner: `import { User, formatName } from '.'`"

## Expected routing
- Skills that should fire: typescript-core + typescript-architecture
- Skills that must NOT fire: typescript-type-level, typescript-boundaries, typescript-async, typescript-migration

## Expected behavior
- Rules applied: barrels are a smell; export from the module, import from the module
- Rationalization tempted: "Barrel files make imports cleaner"
- Expected rebuttal: they make imports shorter and graphs worse: cycles, dead code retention, and refactor landslides. Import from the real module

## What verification must catch
Diff hygiene: no new barrel file added; cycle check (`madge --circular src/` if available) shows zero cycles

## Pass criteria
- Routing: core + architecture fire
- Behavior: the barrel is refused; callers import from the defining modules
# eval: anti-trigger

## Scenario
"Write a bash script that greps today's error logs, summarizes the counts per service, and emails a digest to the on-call engineer."

## Expected routing
- Skill that should fire: none of the pack
- Skills that must NOT fire: typescript-core, typescript-type-level, typescript-boundaries, typescript-async, typescript-architecture, typescript-migration

## Expected behavior
- Rules applied: none from this pack; the agent writes a shell script without TypeScript discipline (no tsconfig advice, no `satisfies`/`unknown` rules, no verification gate invented for bash)
- Rationalization tempted: "the word 'error' plus 'logs' resembles the domain vocabulary"
- Expected rebuttal: routing false-positives are the most common pack defect; the domain is shell scripting, not TypeScript

## What verification must catch
Routing only: no pack skill activates; no TypeScript-specific rules appear in the response

## Pass criteria
- Routing: zero skills from the pack fire
- Behavior: the answer contains bash, not TypeScript discipline
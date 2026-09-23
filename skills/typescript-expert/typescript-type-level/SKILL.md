---
name: typescript-type-level
description: Advanced type construction — conditional types, infer, mapped types,
  template literals, variance, overloads, generic constraints, branded types. Also
  the when-NOT-to-use judgment for advanced types. Use when writing complex
  generics, designing library or DSL types, or when types become the hard part.
metadata:
  version: "1.0.0"
---

# TypeScript Type-Level Discipline

## Overview
Rules for constructing and judging advanced types. This skill owns both the
techniques and the restraint: the best type system is the simplest one that
makes invalid usage impossible.

## When to Use
- Writing or debugging complex generics, conditional types, `infer`, mapped types, template literal types
- Designing library APIs, DSLs, or reusable type utilities
- Variance errors, overload resolution problems
- Any moment the temptation to write a "clever" type appears

## Discipline

### Pre-flight
1. State in one sentence what the type must make impossible. If you can't,
   you don't have a design — you have a puzzle.
2. Check whether an existing utility (Pick/Omit/Partial/Record/Extract/Exclude/Awaited/ReturnType)
   already does the job. Built-ins before hand-rolled.

### In-flight
- Prefer constraint + conditional over overload pile-ups; prefer overloads only
  when signatures genuinely differ in shape.
- Use `infer` in conditional positions to pull types apart; avoid nested `infer`
  more than two levels deep.
- Derive, don't duplicate: `keyof typeof CONFIG`, `(typeof arr)[number]` —
  one source of truth for literal-derived types.
- Branded types for identity that matters (IDs, currencies); nominal-ish checks
  where mixing is a real bug.
- Annotate variance (`in`/`out`) on generic class/interface positions when the
  compiler asks; understand why before adding (see references/variance.md).
- Public API types get explicit annotations; internal code leans on inference.

### The simplicity gate (this skill's core judgment)
Before committing any advanced type, verify ALL of:
1. **One-use rule:** every generic parameter appears at least twice, or
   constrains something. A parameter used once is decoration.
2. **Readable errors:** write a usage error case and read the resulting message.
   If a user can't locate the mistake from the message, simplify the type.
3. **Comment budget:** the type's doc comment should be shorter than the type.
   If not, split or simplify.
4. **Plain alternative check:** name the plain-TS alternative (union, function
   overload, runtime guard). If it exists and costs less than 10 lines, use it.
5. **No `as` inside your own types.** A library's types that need casts are
   broken for its users.

### Post-flight
Run the core verification gate, plus: if the type is public API, write at
least one `expect-type` test asserting both a valid and an invalid usage.

## Rationalizations

| Excuse | Rebuttal |
|---|---|
| "It's self-documenting" | Then the error messages will be readable. Write the error case and check. Complex types fail users at their worst moment: when something's wrong. |
| "It's clever" | Cleverness is a cost paid by every reader after you, including you in three weeks. |
| "Users can just cast" | Users casting to use your API means the API types are wrong. Fix the types. |
| "It needs to be generic over everything" | It needs to be generic over its actual callers. YAGNI applies to type parameters. |
| "The error message is TS's problem" | You chose the type shape; you chose the error. Simplify until the message guides. |
| "Built-ins can't express this" | Sometimes true. Show the plain attempt first, then escalate. |

## Red Flags
- A generic parameter used exactly once
- `extends any` or unconstrained `T` "for flexibility"
- `infer` nested more than two levels
- A type longer than its comment
- `as` inside type/library definitions
- Error messages you yourself can't parse on first read

## Verification
1. Full core gate (tsc, lint, tests, diff hygiene)
2. Type-level tests: at least one valid-usage and one invalid-usage assertion
   per exported type
3. Read an actual compiler error produced by wrong usage — quote it in the PR

## References
- references/type-recipes.md — common recipes (DeepReadonly, Prettify, derived types, branded types)
- references/variance.md — variance, `in`/`out`, structural vs nominal

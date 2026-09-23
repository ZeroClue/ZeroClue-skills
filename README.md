# ZeroClue Skills

[![skills.sh](https://skills.sh/b/ZeroClue/ZeroClue-skills)](https://skills.sh/ZeroClue/ZeroClue-skills)

Agent skill packs and standalone skills for coding agents, built to the
agentskills.io spec. Every skill is self-contained and installable alone.

## Units

| Unit | Type | Domain | Skills | Baseline |
|------|------|---------|--------|----------|
| typescript-expert | pack | Production TypeScript discipline | 6 | typescript-core |

## Install

**skills.sh (recommended)**
```bash
npx skills@latest add ZeroClue/ZeroClue-skills
```
The CLI discovers skills under `skills/` and lets you pick skills and target
agent. Works for Claude Code, Cursor, Codex, opencode, Pi, and 75+ others.

**Specific skills**
```bash
npx skills@latest add ZeroClue/ZeroClue-skills --skill typescript-core -a opencode
```

**Manual copy**
The installer handles 80+ agents and their destination paths. If you must
copy by hand, use the [skills.sh agent table](https://skills.sh/docs/cli)
as the source of record for per-agent directories.

Pack details: [typescript-expert](skills/typescript-expert/README.md)

## Validation

```bash
scripts/validate-pack.sh skills/typescript-expert
```

Authoring-time only. Packs carry no dependency on the validator and remain
self-contained for per-skill installs.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
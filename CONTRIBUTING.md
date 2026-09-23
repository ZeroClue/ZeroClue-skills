# Contributing

Units in this repo (packs and standalone skills) are built via a
grill, research, design, review-gate, build, verify, register process. The
design contract for each public unit is its `DECISIONS.md`; the design
rationale lives there, and the unit's own files are the source of truth.

## Adding a pack or standalone skill

1. **Design first**: scope and out-of-scope, trigger conditions (one per
   skill, non-overlapping), anatomy (Discipline for coding rules, Process for
   workflows), verification commands, eval plan. See the repo governance
   (`AGENTS.md`) for the standards.
2. **Review gate**: present the design to the maintainers and stop for
   explicit approval. No building before approval.
3. **Build**: faithful transcription of the approved design. No redesign in
   the build step.
4. **Verify**: `scripts/validate-pack.sh <pack-dir>` exits 0; evals authored
   (at least one per skill, structured per the eval format in governance).

## PR checklist

- [ ] `scripts/validate-pack.sh <pack-dir>` exits 0
- [ ] At least one eval per skill, with complete expected routing sets
- [ ] `DECISIONS.md` added or updated (decisions, alternatives, source status)
- [ ] No shared root `references/` (self-containment: references live inside
      each skill)
- [ ] Version bumped per changed skill (`metadata.version`)
- [ ] SKILL.md bodies cache-stable: no dates, no recency claims, no version
      pins

## Modifying an existing pack

Run the pack's evals before and after your change. A red eval after a green
one means the change regressed routing or a rule: fix the change, or update
the eval with a decision-record note in `DECISIONS.md` saying why.
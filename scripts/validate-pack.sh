#!/usr/bin/env bash
# validate-pack.sh <pack-dir>
# Parameterized authoring-time validator for a skill pack directory.
#
# Two shapes are handled:
#   - multi-skill pack:  <pack>/<skill>/SKILL.md for each skill directory
#   - single-skill pack: <pack>/SKILL.md at the pack root
#
# Checks: frontmatter (agentskills.io spec), anatomy (Discipline or Process,
# inferred from the section heading), heading order, reference existence,
# self-containment, body budgets, cache stability, fenced code blocks,
# eval presence + structure, and sibling-description overlap.
#
# Packs themselves carry no runtime dependency on this script.

set -euo pipefail

PACK_DIR="${1:-}"
if [[ -z "$PACK_DIR" || ! -d "$PACK_DIR" ]]; then
  echo "usage: validate-pack.sh <pack-dir>"
  exit 2
fi
PACK_DIR="${PACK_DIR%/}"
PACK_NAME=$(basename "$PACK_DIR")

FAILURES=0
fail() { echo "FAIL: $1"; FAILURES=$((FAILURES+1)); }
warn() { echo "warn: $1"; }
pass() { echo "pass: $1"; }

# ---------- helpers ----------

frontmatter_of() { # $1: file -> stdout: frontmatter between first two '---'
  awk '/^---$/ { c++; if (c == 1) { inf = 1; next } if (c == 2) { inf = 0 } } inf { print }' "$1"
}

body_of() { # $1: file -> stdout: everything after the second '---'
  awk '/^---$/ { c++; next } c >= 2 { print }' "$1"
}

check_fences() { # $1: file, $2: label
  local file="$1" label="$2" line tag in_fence=0 open_line=0 ln=0
  while IFS= read -r line; do
    ln=$((ln + 1))
    case "$line" in
      '```'*)
        if [[ $in_fence -eq 0 ]]; then
          in_fence=1
          open_line=$ln
          tag="${line:3}"
          tag="${tag//[[:space:]]/}"
          if [[ -z "$tag" ]]; then
            warn "$label: opening fence at line $ln has no language tag"
          fi
        else
          in_fence=0
        fi
        ;;
    esac
  done < "$file"
  if [[ $in_fence -eq 1 ]]; then
    fail "$label: unbalanced code fence (opened at line $open_line)"
  fi
}

ngrams_of() { # $1: text -> stdout: sorted unique lowercase 4-grams
  printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]' | awk '{
    gsub(/[^a-z0-9 ]/, " ")
    n = split($0, w, " ")
    for (i = 1; i + 3 <= n; i++) print w[i] " " w[i+1] " " w[i+2] " " w[i+3]
  }' | LC_ALL=C sort -u
}

# ---------- per-skill validation ----------

SKILL_COUNT=0
declare -A SKILL_DESCRIPTIONS
SKILL_NAMES=()

validate_skill() { # $1: skill dir, $2: expected skill name (directory basename)
  local sdir="$1" name="$2"
  local md="$sdir/SKILL.md"
  SKILL_COUNT=$((SKILL_COUNT + 1))
  SKILL_NAMES+=("$name")

  if [[ ! -f "$md" ]]; then
    fail "$name: missing SKILL.md"
    SKILL_DESCRIPTIONS[$name]=""
    return
  fi

  # --- frontmatter ---
  if ! head -1 "$md" | grep -q '^---$'; then
    fail "$name: SKILL.md must start with '---' frontmatter"
    SKILL_DESCRIPTIONS[$name]=""
    return
  fi

  local fm
  fm=$(frontmatter_of "$md")

  local fname
  fname=$(printf '%s\n' "$fm" | grep -m1 '^name: ' | sed 's/^name: *//' || true)
  if [[ -z "$fname" ]]; then
    fail "$name: missing 'name' in frontmatter"
  elif [[ "$fname" != "$name" ]]; then
    fail "$name: frontmatter name '$fname' does not match directory name '$name'"
  else
    pass "$name: name matches directory"
  fi

  if ! [[ "$fname" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    fail "$name: name fails ^[a-z0-9]+(-[a-z0-9]+)*\$"
  fi
  if [[ -n "$fname" && ${#fname} -gt 64 ]]; then
    fail "$name: name exceeds 64 characters"
  fi

  if ! printf '%s\n' "$fm" | grep -q '^[[:space:]]*version:'; then
    warn "$name: no metadata.version in frontmatter (per-skill semantic version expected)"
  fi

  # --- description (multi-line folded YAML) ---
  local desc
  desc=$(printf '%s\n' "$fm" | sed -n '/^description:/,/^[a-z]*:/p' | head -n -1 \
    | sed 's/^description: *//' | sed 's/^  //' | tr '\n' ' ' \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  SKILL_DESCRIPTIONS[$name]="$desc"
  if [[ -z "$desc" ]]; then
    fail "$name: empty or missing 'description' in frontmatter"
  elif [[ ${#desc} -gt 1024 ]]; then
    fail "$name: description exceeds 1024 characters (${#desc})"
  else
    pass "$name: description present (${#desc} chars)"
  fi

  # --- anatomy: infer Discipline vs Process, check headings in order ---
  local kind=""
  if grep -q '^## Discipline' "$md"; then
    kind="discipline"
  elif grep -q '^## Process' "$md"; then
    kind="process"
  else
    fail "$name: neither '## Discipline' nor '## Process' section found"
  fi

  if [[ -n "$kind" ]]; then
    local headings=()
    if [[ "$kind" == "discipline" ]]; then
      headings=("## Overview" "## When to Use" "## Discipline" "### Pre-flight" "### In-flight" "### Post-flight" "## Rationalizations" "## Red Flags" "## Verification" "## References")
    else
      headings=("## Overview" "## When to Use" "## Process" "## Rationalizations" "## Red Flags" "## Verification" "## References")
    fi
    local last=0 h pos
    local missing=0
    for h in "${headings[@]}"; do
      pos=$(grep -n "^${h}" "$md" | head -1 | cut -d: -f1 || true)
      if [[ -z "${pos:-}" ]]; then
        fail "$name: missing heading '$h'"
        missing=1
      else
        if [[ $pos -le $last ]]; then
          fail "$name: heading '$h' out of order (line $pos, previous at $last)"
        fi
        last=$pos
      fi
    done
    if [[ $missing -eq 0 ]]; then
      pass "$name: $kind anatomy headings present and in order"
    fi
  fi

  # --- references: every references/*.md named in SKILL.md exists in-skill ---
  local ref
  while IFS= read -r ref; do
    if [[ ! -f "$sdir/$ref" ]]; then
      fail "$name: references/$ref named in SKILL.md but not found in skill directory"
    fi
  done < <(grep -oE 'references/[a-z0-9-]+\.md' "$md" | sort -u)
  pass "$name: referenced files resolve in-skill"

  # --- body checks ---
  local body
  body=$(body_of "$md")

  local chars
  chars=$(printf '%s' "$body" | wc -c)
  if [[ $chars -gt 6000 ]]; then
    fail "$name: body is $chars chars (over the 6000 budget)"
  else
    pass "$name: body $chars chars (~$((chars / 4)) tokens)"
  fi

  # cache stability: dates and "latest" are failures; bare semver is a warning
  if printf '%s' "$body" | grep -qE '20[0-9]{2}-[0-9]{2}-[0-9]{2}'; then
    fail "$name: ISO date in SKILL.md body (cache stability)"
  fi
  if printf '%s' "$body" | grep -qw 'latest'; then
    fail "$name: 'latest' in SKILL.md body (cache stability)"
  fi
  if printf '%s' "$body" | grep -qE '\b[0-9]+\.[0-9]+\.[0-9]+\b'; then
    warn "$name: semver-like string in SKILL.md body (possible version pin)"
  fi
  pass "$name: cache-stability scan done"

  # self-containment: no escaping paths, no path-shaped skill references.
  # Inline code spans are stripped first: a red-flag rule may legitimately
  # quote an anti-pattern (e.g. '../..') inside backticks.
  local plain_body
  plain_body=$(printf '%s' "$body" | sed 's/`[^`]*`//g')
  if printf '%s' "$plain_body" | grep -q '\.\./'; then
    fail "$name: body contains '../' path (self-containment breach)"
  fi
  if printf '%s' "$plain_body" | grep -qE '[a-z0-9-]+/SKILL\.md'; then
    fail "$name: body references another skill's SKILL.md by path (use skill names only)"
  fi
  pass "$name: self-containment holds"

  # --- fences in SKILL.md and its references ---
  check_fences "$md" "$name/SKILL.md"
  local rfile
  for rfile in "$sdir"/references/*.md; do
    [[ -f "$rfile" ]] || continue
    check_fences "$rfile" "$name/references/$(basename "$rfile")"
  done
}

# ---------- pack shape discovery ----------

SHAPE=""
found_skill=0
if [[ -f "$PACK_DIR/SKILL.md" ]]; then
  # single-skill pack: the pack root is the skill
  validate_skill "$PACK_DIR" "$PACK_NAME"
  SHAPE="single"
  found_skill=1
else
  # multi-skill pack: one directory per skill
  SHAPE="multi"
  for dir in "$PACK_DIR"/*/; do
    [[ -d "$dir" ]] || continue
    if [[ -f "${dir}SKILL.md" ]]; then
      validate_skill "${dir%/}" "$(basename "$dir")"
      found_skill=1
    else
      warn "$PACK_NAME: directory '$(basename "$dir")' has no SKILL.md (authoring-time artifacts only; governance prefers repo-root tooling)"
    fi
  done
fi
if [[ $found_skill -eq 0 ]]; then
  fail "$PACK_NAME: no skill directories with SKILL.md found"
fi

# ---------- pack-root file requirements ----------

if [[ "$SHAPE" == "multi" ]]; then
  for f in README.md AGENTS.md CLAUDE.md CHANGELOG.md DECISIONS.md; do
    if [[ -f "$PACK_DIR/$f" ]]; then
      pass "$PACK_NAME: pack-root $f present"
    else
      fail "$PACK_NAME: missing pack-root $f"
    fi
  done
  for f in "$PACK_DIR"/*; do
    [[ -f "$f" ]] || continue
    b=$(basename "$f")
    case "$b" in
      README.md|AGENTS.md|CLAUDE.md|CHANGELOG.md|DECISIONS.md|LICENSE|SKILL.md) ;;
      *) warn "$PACK_NAME: unexpected pack-root file '$b' (intentional? note it in DECISIONS.md)" ;;
    esac
  done
fi

# ---------- evals ----------

EVALS_DIR="$PACK_DIR/evals"
if [[ ! -d "$EVALS_DIR" ]]; then
  fail "$PACK_NAME: missing evals/ directory (governance requires at least one eval per skill)"
else
  EVAL_COUNT=0
  shopt -s nullglob
  eval_files=("$EVALS_DIR"/*.md)
  shopt -u nullglob
  if [[ ${#eval_files[@]} -eq 0 ]]; then
    fail "$PACK_NAME: evals/ is empty"
  else
    for e in "${eval_files[@]}"; do
      EVAL_COUNT=$((EVAL_COUNT + 1))
      eb="evals/$(basename "$e")"
      head -1 "$e" | grep -q '^# eval: ' || fail "$eb: first line must be '# eval: <short-name>'"
      grep -q '^## Scenario$' "$e" || fail "$eb: missing '## Scenario'"
      grep -q '^## Expected routing$' "$e" || fail "$eb: missing '## Expected routing'"
      grep -q '^## Expected behavior$' "$e" || fail "$eb: missing '## Expected behavior'"
      grep -q '^## What verification must catch$' "$e" || fail "$eb: missing '## What verification must catch'"
      grep -q '^## Pass criteria$' "$e" || fail "$eb: missing '## Pass criteria'"
      check_fences "$e" "$eb"
    done
    pass "$PACK_NAME: $EVAL_COUNT eval file(s), all structurally valid"
    if [[ $EVAL_COUNT -lt $SKILL_COUNT ]]; then
      fail "$PACK_NAME: $EVAL_COUNT evals for $SKILL_COUNT skills (need at least one per skill)"
    fi
  fi
fi

# ---------- sibling-description overlap (routing distinctness heuristic) ----------

if [[ "$SHAPE" == "multi" && ${#SKILL_NAMES[@]} -gt 1 ]]; then
  overlap_found=0
  for ((i = 0; i < ${#SKILL_NAMES[@]}; i++)); do
    for ((j = i + 1; j < ${#SKILL_NAMES[@]}; j++)); do
      a="${SKILL_NAMES[$i]}"
      b="${SKILL_NAMES[$j]}"
      da="${SKILL_DESCRIPTIONS[$a]:-}"
      db="${SKILL_DESCRIPTIONS[$b]:-}"
      [[ -z "$da" || -z "$db" ]] && continue
      shared=$(LC_ALL=C comm -12 <(ngrams_of "$da") <(ngrams_of "$db") | head -3 || true)
      if [[ -n "$shared" ]]; then
        overlap_found=1
        warn "$PACK_NAME: descriptions of '$a' and '$b' share phrase(s): $(printf '%s; ' $shared | sed 's/; $//')"
      fi
    done
  done
  if [[ $overlap_found -eq 0 ]]; then
    pass "$PACK_NAME: no sibling description overlap detected (routing distinctness)"
  fi
fi

# ---------- summary ----------

echo ""
echo "== $PACK_NAME ($SHAPE-skill pack, $SKILL_COUNT skill(s)) =="
if [[ $FAILURES -eq 0 ]]; then
  echo "OK: $PACK_NAME valid"
  exit 0
else
  echo "$FAILURES failure(s) in $PACK_NAME"
  exit 1
fi
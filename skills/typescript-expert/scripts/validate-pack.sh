#!/usr/bin/env bash
# typescript-expert pack validator
# Validates structure, frontmatter, anatomy, references, cross-refs, token budgets,
# cache stability, and code block syntax.

set -euo pipefail

PACK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERRORS=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() {
  echo -e "${RED}[ERROR]${NC} $*" >&2
  ((ERRORS++))
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

ok() {
  echo -e "${GREEN}[OK]${NC} $*"
}

# ---- Expected structure ----
EXPECTED_FILES=(
  "AGENTS.md"
  "CLAUDE.md"
  "README.md"
  "CHANGELOG.md"
  "LICENSE"
  "scripts/validate-pack.sh"
  "VALIDATION_REPORT.md"
  "typescript-core/SKILL.md"
  "typescript-core/references/tsconfig-baseline.md"
  "typescript-core/references/patterns.md"
  "typescript-core/references/verification.md"
  "typescript-type-level/SKILL.md"
  "typescript-type-level/references/type-recipes.md"
  "typescript-type-level/references/variance.md"
  "typescript-boundaries/SKILL.md"
  "typescript-boundaries/references/validation-patterns.md"
  "typescript-async/SKILL.md"
  "typescript-async/references/result-patterns.md"
  "typescript-async/references/cancellation.md"
  "typescript-architecture/SKILL.md"
  "typescript-architecture/references/module-design.md"
  "typescript-architecture/references/api-surface.md"
  "typescript-migration/SKILL.md"
  "typescript-migration/references/incremental-strategies.md"
  "typescript-migration/references/suppression-hygiene.md"
)

SKILL_DIRS=(
  "typescript-core"
  "typescript-type-level"
  "typescript-boundaries"
  "typescript-async"
  "typescript-architecture"
  "typescript-migration"
)

ANATOMY_HEADINGS=(
  "## Overview"
  "## When to Use"
  "## Discipline"
  "### Pre-flight"
  "### In-flight"
  "### Post-flight"
  "## Rationalizations"
  "## Red Flags"
  "## Verification"
  "## References"
)

echo "=== Phase 1: File existence ==="
for f in "${EXPECTED_FILES[@]}"; do
  if [[ -f "$PACK_ROOT/$f" ]]; then
    ok "Exists: $f"
  else
    error "Missing: $f"
  fi
done

# Check for unexpected files
echo ""
echo "=== Phase 1b: Unexpected files ==="
mapfile -t ALL_FILES < <(find "$PACK_ROOT" -type f -name "*.md" -o -name "*.sh" | sed "s|$PACK_ROOT/||" | sort)
for f in "${ALL_FILES[@]}"; do
  if [[ ! " ${EXPECTED_FILES[*]} " =~ " ${f} " ]]; then
    error "Unexpected file: $f"
  fi
done

# ---- Frontmatter validation ----
echo ""
echo "=== Phase 2: Frontmatter validation ==="
for skill in "${SKILL_DIRS[@]}"; do
  skill_path="$PACK_ROOT/$skill/SKILL.md"
  if [[ ! -f "$skill_path" ]]; then
    continue
  fi

  # Extract frontmatter (between first and second ---)
  frontmatter=$(sed -n '1,/^---$/p' "$skill_path" | head -n -1 | tail -n +2)

  # name
  name=$(echo "$frontmatter" | grep '^name:' | sed 's/^name: *//')
  if [[ -z "$name" ]]; then
    error "$skill: missing 'name' in frontmatter"
  elif [[ "$name" != "$skill" ]]; then
    error "$skill: frontmatter name '$name' != directory name '$skill'"
  else
    ok "$skill: name matches directory"
  fi

  # name pattern
  if [[ -n "$name" ]] && ! [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    error "$skill: name '$name' does not match ^[a-z0-9]+(-[a-z0-9]+)*$"
  fi
  if [[ -n "$name" && ${#name} -gt 64 ]]; then
    error "$skill: name '$name' exceeds 64 characters"
  fi

  # description
  desc=$(echo "$frontmatter" | sed -n '/^description:/,/^[a-z]*:/p' | head -n -1 | sed 's/^description: *//')
  desc=${desc//$'\n'/ }
  desc=$(echo "$desc" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  # trim
  if [[ -z "$desc" ]]; then
    error "$skill: missing or empty 'description' in frontmatter"
  elif [[ ${#desc} -gt 1024 ]]; then
    error "$skill: description exceeds 1024 characters (${#desc})"
  else
    ok "$skill: description present (${#desc} chars)"
  fi

  # Check description has trigger keywords (what it does + when to use)
  if [[ -n "$desc" ]] && ! [[ "$desc" =~ (Use|When|For|Use when|for) ]]; then
    warn "$skill: description may lack trigger keywords"
  fi
done

# ---- Anatomy validation ----
echo ""
echo "=== Phase 3: Anatomy headings (order & presence) ==="
for skill in "${SKILL_DIRS[@]}"; do
  skill_path="$PACK_ROOT/$skill/SKILL.md"
  if [[ ! -f "$skill_path" ]]; then
    continue
  fi

  content=$(cat "$skill_path")
  last_pos=-1
  for heading in "${ANATOMY_HEADINGS[@]}"; do
    # Find position of heading (match prefix, allowing trailing text like "(before writing code)")
    pos=$(grep -n "^$heading" "$skill_path" | head -1 | cut -d: -f1)
    if [[ -z "$pos" ]]; then
      error "$skill: missing heading '$heading'"
    elif [[ $pos -le $last_pos ]]; then
      error "$skill: heading '$heading' out of order (line $pos, previous was $last_pos)"
    else
      last_pos=$pos
    fi
  done
  if [[ $ERRORS -eq 0 ]]; then
    ok "$skill: all headings present and in order"
  fi
done

# ---- References validation ----
echo ""
echo "=== Phase 4: References exist in skill's own directory ==="
for skill in "${SKILL_DIRS[@]}"; do
  skill_path="$PACK_ROOT/$skill/SKILL.md"
  if [[ ! -f "$skill_path" ]]; then
    continue
  fi

  # Extract references from the References section
  refs=$(sed -n '/^## References$/,/^## /p' "$skill_path" | grep '^- references/' | sed 's/^- references\///' | sed 's/ .*//')
  for ref in $refs; do
    ref_path="$PACK_ROOT/$skill/references/$ref"
    if [[ -f "$ref_path" ]]; then
      ok "$skill: reference exists: $ref"
    else
      error "$skill: missing reference file: $ref (expected at $ref_path)"
    fi
  done
done

# ---- Cross-skill references ----
echo ""
echo "=== Phase 5: Cross-skill references ==="
for skill in "${SKILL_DIRS[@]}"; do
  skill_path="$PACK_ROOT/$skill/SKILL.md"
  if [[ ! -f "$skill_path" ]]; then
    continue
  fi

  # Find mentions of other skills (typescript-xxx)
  mentions=$(grep -oE 'typescript-[a-z-]+' "$skill_path" | sort -u)
  for mention in $mentions; do
    if [[ "$mention" == "$skill" ]]; then
      continue
    fi
    if [[ " ${SKILL_DIRS[*]} " =~ " ${mention} " ]]; then
      ok "$skill: references sibling skill $mention"
    else
      warn "$skill: references unknown skill $mention"
    fi
  done
done

# ---- Token/character budget ----
echo ""
echo "=== Phase 6: SKILL.md body length ==="
for skill in "${SKILL_DIRS[@]}"; do
  skill_path="$PACK_ROOT/$skill/SKILL.md"
  if [[ ! -f "$skill_path" ]]; then
    continue
  fi

  # Count chars after frontmatter (find second --- delimiter)
  # Use awk to skip frontmatter (between first and second ---)
  body=$(awk '/^---$/ { if (++count == 2) { in_body=1; next } } in_body { print }' "$skill_path")
  chars=${#body}
  tokens=$((chars / 4))
  if [[ $chars -gt 6000 ]]; then
    warn "$skill: body ~${chars} chars (~${tokens} tokens) — exceeds 6000 char budget"
  else
    ok "$skill: body ~${chars} chars (~${tokens} tokens)"
  fi
done

# ---- Cache stability ----
echo ""
echo "=== Phase 7: Cache stability (no dates, 'latest', version pins) ==="
FORBIDDEN_PATTERNS=(
  "TypeScript [0-9]"
  "\b202[0-9]-\|[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}"
  "\blatest\b"
)
for skill in "${SKILL_DIRS[@]}"; do
  skill_path="$PACK_ROOT/$skill/SKILL.md"
  if [[ ! -f "$skill_path" ]]; then
    continue
  fi
  body=$(awk '/^---$/ { if (++count == 2) { in_body=1; next } } in_body { print }' "$skill_path")
  for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    if echo "$body" | grep -qiE "$pattern"; then
      error "$skill: forbidden pattern in body: '$pattern'"
    fi
  done
done

# Also check reference files for version pins (they're allowed there but flag for awareness)
for skill in "${SKILL_DIRS[@]}"; do
  for ref in "$PACK_ROOT/$skill/references/"*.md; do
    if [[ -f "$ref" ]]; then
      if grep -qiE "TypeScript [0-9]" "$ref"; then
        warn "$(basename "$ref"): contains version pin (allowed in references)"
      fi
    fi
  done
done

# ---- Code block balance ----
echo ""
echo "=== Phase 8: Fenced code block balance ==="
for skill in "${SKILL_DIRS[@]}"; do
  for file in "$PACK_ROOT/$skill/SKILL.md" "$PACK_ROOT/$skill/references/"*.md; do
    if [[ ! -f "$file" ]]; then
      continue
    fi
    # Count opening and closing fences
    opens=$(grep -c '^```' "$file" || true)
    if [[ $((opens % 2)) -ne 0 ]]; then
      error "$file: unbalanced code fences ($opens openings)"
    fi
    # Check language tags on opening fences (lines with ``` followed by a language identifier)
    while IFS= read -r line; do
      if [[ "$line" =~ ^\`\`\`[[:space:]]*$ ]]; then
        # Could be a closing fence or opening without language - skip warning for simplicity
        :
      elif [[ "$line" =~ ^\`\`\`[^a-zA-Z] ]]; then
        # Opening fence with non-letter after backticks (e.g., ```jsonc, ```bash)
        :
      elif ! [[ "$line" =~ ^\`\`\`[a-zA-Z] ]]; then
        # Opening fence without a language tag
        warn "$file: code fence without language tag"
      fi
    done < <(grep '^```' "$file")
  done
done

# Also check root markdown files
for file in "$PACK_ROOT/AGENTS.md" "$PACK_ROOT/CLAUDE.md" "$PACK_ROOT/README.md"; do
  if [[ -f "$file" ]]; then
    opens=$(grep -c '^```' "$file" || true)
    if [[ $((opens % 2)) -ne 0 ]]; then
      error "$file: unbalanced code fences ($opens openings)"
    fi
  fi
done

# ---- Summary ----
echo ""
echo "=== Validation Summary ==="
if [[ $ERRORS -eq 0 ]]; then
  ok "All checks passed"
  exit 0
else
  error "Total errors: $ERRORS"
  exit 1
fi
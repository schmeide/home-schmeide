#!/usr/bin/env bash
# Fails when a pull request carries AI attribution: the Claude Code footer in its
# title, description or a commit message, a commit message the commit-msg hook
# rejects, or a commit authored with an Anthropic address.
# Usage: scripts/check_attribution.sh <pull request number>
# The pull request is read fresh through gh rather than from the workflow's event
# payload, which a re-run would reuse unchanged.
set -euo pipefail

pr="${1:-}"
if [[ -z "${pr}" ]]; then
  echo "Usage: make check/attribution PR=<pull request number>"
  exit 1
fi
if ! command -v gh >/dev/null 2>&1; then
  echo "gh is not installed. Install the GitHub CLI (https://cli.github.com), then run 'gh auth login'."
  exit 1
fi

root="$(cd "$(dirname "$0")/.." && pwd)"
footer='Generated with [Claude Code](https://claude.com/claude-code)'

if ! json="$(gh pr view "${pr}" --json title,body,commits)"; then
  echo "Could not read pull request #${pr}. Check the number, and run 'gh auth login' (in CI, set GH_TOKEN)."
  exit 1
fi

failed=0

lines="$(jq -r '"title: " + .title, (.body | split("\n")[] | "description: " + .), (.commits[] | "commit \(.oid[0:8]): " + (.messageHeadline, (.messageBody | split("\n")[])))' <<<"${json}")"
if hits="$(printf '%s\n' "${lines}" | tr -d '\r' | grep -F -- "${footer}")"; then
  echo "Pull request #${pr} carries the Claude Code attribution footer:"
  echo ""
  printf '%s\n' "${hits}" | sed 's/^/  /'
  echo ""
  failed=1
fi

message_file="$(mktemp)"
trap 'rm -f "${message_file}"' EXIT
count="$(jq '.commits | length' <<<"${json}")"
for ((i = 0; i < count; i++)); do
  oid="$(jq -r ".commits[${i}].oid[0:8]" <<<"${json}")"
  jq -r ".commits[${i}] | .messageHeadline + \"\n\n\" + .messageBody" <<<"${json}" >"${message_file}"
  if ! output="$(GIT_DIR="${root}/.git" "${root}/git/hooks/commit-msg" "${message_file}" 2>&1)"; then
    echo "Commit ${oid}:"
    printf '%s\n' "${output}" | sed 's/^/  /'
    failed=1
  fi
  if authors="$(jq -r ".commits[${i}].authors[] | \"\(.name) <\(.email)>\"" <<<"${json}" | grep -iE 'anthropic\.com')"; then
    echo "Commit ${oid} is authored with an Anthropic address:"
    printf '%s\n' "${authors}" | sed 's/^/  /'
    echo ""
    failed=1
  fi
done

if ((failed)); then
  echo "Remove the attribution: edit the pull request title or description, or amend the commits"
  echo "(git commit --amend --reset-author) and push. Then re-run this check."
  exit 1
fi
echo "Pull request #${pr} carries no AI attribution."

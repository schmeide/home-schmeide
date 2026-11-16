#!/usr/bin/env bash
# Vendors the design skills from jakubkrehel/skills into a .claude/skills folder.
# Only the Markdown is copied; the per-agent agents/ folders are left out.
# Usage: scripts/vendor_skills.sh <commit or branch> [destination]
# The destination defaults to this repo's .claude/skills. Pass another repo's
# .claude/skills to vendor the same commit there.
set -euo pipefail

ref="${1:-}"
if [[ -z "${ref}" ]]; then
  echo "Usage: make skills/update REF=<commit or branch> [DEST=<.claude/skills folder>]"
  exit 1
fi
root="$(cd "$(dirname "$0")/.." && pwd)"
dest="${2:-${root}/.claude/skills}"

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
git clone -q https://github.com/jakubkrehel/skills "${tmp}/upstream"
git -C "${tmp}/upstream" checkout -q "${ref}"
commit="$(git -C "${tmp}/upstream" rev-parse HEAD)"

mkdir -p "${dest}"
for skill in "${tmp}"/upstream/skills/*/; do
  name="$(basename "${skill}")"
  rm -rf "${dest:?}/${name}"
  mkdir -p "${dest}/${name}"
  (cd "${skill}" && find . -type f -name '*.md' -exec cp --parents {} "${dest}/${name}/" \;)
done
cp "${tmp}/upstream/LICENSE" "${dest}/LICENSE"
printf '%s\n' "${commit}" > "${dest}/UPSTREAM_COMMIT"
echo "Vendored jakubkrehel/skills at ${commit} into ${dest}"

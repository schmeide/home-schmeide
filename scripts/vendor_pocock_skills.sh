#!/usr/bin/env bash
# Vendors the skills that mattpocock/skills ships in its Claude Code plugin
# (skills/engineering and skills/productivity) into a .claude/skills folder.
# The misc/ and in-progress/ skills and the per-agent agents/ folders are left out.
# Usage: scripts/vendor_pocock_skills.sh <commit or branch> [destination]
set -euo pipefail

ref="${1:-}"
if [[ -z "${ref}" ]]; then
  echo "Usage: make skills/update-pocock REF=<commit or branch> [DEST=<.claude/skills folder>]"
  exit 1
fi
root="$(cd "$(dirname "$0")/.." && pwd)"
dest="${2:-${root}/.claude/skills}"

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
git clone -q https://github.com/mattpocock/skills "${tmp}/upstream"
git -C "${tmp}/upstream" checkout -q "${ref}"
commit="$(git -C "${tmp}/upstream" rev-parse HEAD)"

mkdir -p "${dest}"
for skill in "${tmp}"/upstream/skills/engineering/*/ "${tmp}"/upstream/skills/productivity/*/; do
  name="$(basename "${skill}")"
  rm -rf "${dest:?}/${name}"
  mkdir -p "${dest}/${name}"
  (cd "${skill}" && find . -type f -not -path './agents/*' -exec cp --parents {} "${dest}/${name}/" \;)
done
cp "${tmp}/upstream/LICENSE" "${dest}/LICENSE-mattpocock"
printf '%s\n' "${commit}" > "${dest}/UPSTREAM_COMMIT_MATTPOCOCK"
echo "Vendored mattpocock/skills at ${commit} into ${dest}"

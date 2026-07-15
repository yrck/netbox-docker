#!/bin/bash
# Pull latest changes from netbox-community/netbox-docker (upstream)
# into the local release branch, then push to origin (your fork).
#
# Prerequisites:
#   git remote add upstream https://github.com/netbox-community/netbox-docker.git
#   git remote add origin <your-internal-fork-url>
#
# Usage:
#   ./sync-upstream.sh

set -euo pipefail

BRANCH="${BRANCH:-release}"
UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
ORIGIN_REMOTE="${ORIGIN_REMOTE:-origin}"

cd "$(dirname "$0")"

if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
  echo "error: remote '$UPSTREAM_REMOTE' is not configured." >&2
  echo "  git remote add $UPSTREAM_REMOTE https://github.com/netbox-community/netbox-docker.git" >&2
  exit 1
fi

if ! git remote get-url "$ORIGIN_REMOTE" >/dev/null 2>&1; then
  echo "error: remote '$ORIGIN_REMOTE' is not configured." >&2
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
  echo "error: working tree is not clean. Commit, stash, or discard local changes first." >&2
  git status -sb
  exit 1
fi

echo "Fetching from $UPSTREAM_REMOTE..."
git fetch "$UPSTREAM_REMOTE"

echo "Checking out $BRANCH..."
git checkout "$BRANCH"

echo "Merging $UPSTREAM_REMOTE/$BRANCH into $BRANCH..."
git merge "$UPSTREAM_REMOTE/$BRANCH"

echo "Pushing $BRANCH to $ORIGIN_REMOTE..."
git push "$ORIGIN_REMOTE" "$BRANCH"

echo "Done. $BRANCH is synced from $UPSTREAM_REMOTE and pushed to $ORIGIN_REMOTE."

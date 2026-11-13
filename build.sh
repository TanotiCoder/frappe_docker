#!/usr/bin/env bash
# Build oxygan-bench:16 from LOCAL app source. No git token, no ERPNext.
set -euo pipefail
cd "$(dirname "$0")"

APP_SRC="${APP_SRC:-/home/sai-dubey/Documents/frappe/ThreadERP/frappe-bench/apps/sme_crm}"
CTX="$(pwd)"
BRANCH="${FRAPPE_BRANCH:-version-16}"

[ -f "$CTX/images/layered/Containerfile" ] || { echo "Error: Not a frappe_docker checkout: $CTX"; exit 1; }
[ -d "$APP_SRC/sme_crm" ] || { echo "Error: App source not found at: $APP_SRC"; exit 1; }

echo "==> Copying local app source from $APP_SRC..."
rm -rf "$CTX/sme_crm_src"
mkdir -p "$CTX/sme_crm_src"
rsync -a --exclude node_modules --exclude __pycache__ --exclude '*.pyc' \
  "$APP_SRC/" "$CTX/sme_crm_src/"

# Snapshot working tree so local uncommitted edits are included
git -C "$CTX/sme_crm_src" init -q || true
git -C "$CTX/sme_crm_src" -c user.email=build@local -c user.name=build add -A
git -C "$CTX/sme_crm_src" -c user.email=build@local -c user.name=build commit -qm "build snapshot" || true

trap 'rm -rf "$CTX/sme_crm_src"' EXIT

echo "==> Building Docker image oxygan-bench:16 (Frappe branch: $BRANCH)..."
docker build \
  --build-arg=FRAPPE_BRANCH="$BRANCH" \
  --tag=oxygan-bench:16 \
  --file="$CTX/Containerfile.local" \
  "$CTX"

echo "==> Build successful: oxygan-bench:16"


#!/usr/bin/env bash
# Create a new shop site on the running stack in 1 command.
# Usage:
#   ./newshop.sh shop1.oxygan.in [admin_password]
set -euo pipefail
cd "$(dirname "$0")"

SITE="${1:?Usage: ./newshop.sh <site.domain> [admin-password]}"
ADMIN_PASSWORD="${2:-admin}"

echo "=================================================="
echo "==> Creating new shop: $SITE"
echo "=================================================="

# Run bench new-site inside the running backend container
docker compose -f pwd.yml exec -T backend bench new-site "$SITE" \
  --mariadb-user-host-login-scope='%' \
  --db-root-username root \
  --db-root-password admin \
  --admin-password "$ADMIN_PASSWORD" \
  --install-app sme_crm

docker compose -f pwd.yml exec -T backend bench --site "$SITE" set-config host_name "http://$SITE:8080"

echo
echo "=================================================="
echo "  SHOP CREATED SUCCESSFULLY!"
echo "=================================================="
echo "  URL   : http://$SITE:8080"
echo "  User  : Administrator"
echo "  Pass  : $ADMIN_PASSWORD"
echo "=================================================="


#!/bin/bash
# Start script for the Sure Railway template.
set -euo pipefail

# Fixed settings for a single-instance, self-hosted deploy behind Railway's HTTPS edge.
export SELF_HOSTED="${SELF_HOSTED:-true}"
export RAILS_FORCE_SSL="${RAILS_FORCE_SSL:-true}"
export RAILS_ASSUME_SSL="${RAILS_ASSUME_SSL:-true}"
export RAILS_MAX_THREADS="${RAILS_MAX_THREADS:-3}"
export PORT="${PORT:-3000}"
# With ADMIN_EMAIL set, sign-up stays closed: the first admin comes from
# ADMIN_EMAIL / ADMIN_PASSWORD. Admins can switch to "invite only" or "open"
# later in Settings > Self-Hosting. Without it, the first visitor to sign up
# becomes the admin (upstream default).
if [ -n "${ADMIN_EMAIL:-}" ]; then
  export ONBOARDING_STATE="${ONBOARDING_STATE:-closed}"
fi
# No SMTP by default, so don't hold email changes for a confirmation mail.
export REQUIRE_EMAIL_CONFIRMATION="${REQUIRE_EMAIL_CONFIRMATION:-false}"

# Railway mounts volumes owned by root, but Sure runs as the rails user (uid 1000).
# Fix ownership of the storage volume once, then re-run this script as uid 1000.
if [ "$(id -u)" = "0" ]; then
  mkdir -p /rails/storage
  if [ "$(stat -c %u /rails/storage)" != "1000" ]; then
    chown -R 1000:1000 /rails/storage
  fi
  export HOME=/home/rails
  exec setpriv --reuid=1000 --regid=1000 --init-groups "$0" "$@"
fi

cd /rails
echo "[sure-railway] preparing database"
./bin/rails db:prepare

if [ -n "${ADMIN_EMAIL:-}" ] && [ -n "${ADMIN_PASSWORD:-}" ]; then
  echo "[sure-railway] checking first admin"
  ./bin/rails runner /rails/railway/bootstrap_admin.rb
fi

echo "[sure-railway] starting Sidekiq and Puma"
bundle exec sidekiq &
SIDEKIQ_PID=$!
./bin/rails server -b 0.0.0.0 -p "${PORT}" &
WEB_PID=$!

shutdown() {
  kill -TERM "$WEB_PID" "$SIDEKIQ_PID" 2>/dev/null || true
}
trap shutdown TERM INT

# If either process exits, stop the other and exit so Railway restarts the service.
set +e
wait -n "$WEB_PID" "$SIDEKIQ_PID"
CODE=$?
echo "[sure-railway] a process exited with code ${CODE}; stopping"
shutdown
wait
exit "$CODE"

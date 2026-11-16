# Sure on Railway: official image, pinned by version and digest.
# Upstream: https://github.com/we-promise/sure
FROM ghcr.io/we-promise/sure:0.7.6-hotfix.1@sha256:002cde609f3af4b69ba2564c2482f3996e1fe29092dd169962b9b6ed943fcb10

# Start as root only to fix volume ownership; start.sh drops to uid 1000 (rails).
USER root
COPY --chown=1000:1000 --chmod=755 railway/start.sh /rails/railway/start.sh
COPY --chown=1000:1000 railway/bootstrap_admin.rb /rails/railway/bootstrap_admin.rb

# The upstream entrypoint enables jemalloc and then runs CMD.
# start.sh prepares the database, creates the first admin, and runs
# Puma (web) and Sidekiq (jobs) side by side so both use /rails/storage.
CMD ["/rails/railway/start.sh"]

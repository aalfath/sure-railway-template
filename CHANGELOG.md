# Changelog

## Unreleased (2026-11-16)

- README: add the Deploy on Railway button for the published template `sure-1`. No change to the app or its configuration.

## 0.7.6-hotfix.1 (2026-11-16)

- First release of the template: Sure `0.7.6-hotfix.1` (`ghcr.io/we-promise/sure`, digest `sha256:002cde60…`), Railway Postgres and Redis.
- Web and Sidekiq run in one service sharing the `/rails/storage` volume.
- The first admin is created from `ADMIN_EMAIL` / `ADMIN_PASSWORD`; public sign-up is closed by default.

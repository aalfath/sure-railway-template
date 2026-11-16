# Sure on Railway

A Railway template for [Sure](https://github.com/we-promise/sure), the open-source personal finance app (community successor of Maybe Finance): net worth, accounts, transactions, budgets, investments and reports.

**Version:** Sure `0.7.6-hotfix.1`, from the official image `ghcr.io/we-promise/sure:0.7.6-hotfix.1@sha256:002cde609f3af4b69ba2564c2482f3996e1fe29092dd169962b9b6ed943fcb10`.

## What it deploys

| Service | Source | Notes |
|---|---|---|
| `Sure` | this repo (`Dockerfile`) | Puma web server and Sidekiq jobs in one container, so both share the `/rails/storage` volume (uploads, exports). Public domain, health check `/up`. |
| `Postgres` | Railway Postgres | Database, on its own volume. |
| `Redis` | Railway Redis | Sidekiq queue and Rails cache. |

At every boot, `railway/start.sh` runs `rails db:prepare` (creates or migrates the database) and, if no user exists yet, creates the first admin from `ADMIN_EMAIL` and `ADMIN_PASSWORD` (`railway/bootstrap_admin.rb`). Public sign-up is closed by default; the admin can open it or switch to invite-only in **Settings → Self-Hosting**.

## Variables (`Sure` service)

| Variable | Default | Notes |
|---|---|---|
| `ADMIN_EMAIL` | *(you enter it)* | Email of the first admin account. |
| `ADMIN_PASSWORD` | generated | Password of the first admin. Read it in the service's Variables tab. Used only while no user exists, so changing it later does nothing; change the password in the app instead. |
| `SECRET_KEY_BASE` | generated | Rails secret for sessions and encrypted fields. Never change it after setup. |
| `DB_HOST`, `DB_PORT`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` | references to `Postgres` | Database connection. |
| `REDIS_URL` | reference to `Redis` | Redis connection. |
| `APP_DOMAIN` | `${{RAILWAY_PUBLIC_DOMAIN}}` | Host used in links in emails. |
| `PORT` | `3000` | Port Puma listens on. |

Optional, add them yourself when you need them (see Sure's [`.env.example`](https://github.com/we-promise/sure/blob/main/.env.example)): `SMTP_*` and `EMAIL_SENDER` for email, `OPENAI_ACCESS_TOKEN` (or another LLM provider) for the AI assistant, `TWELVE_DATA_API_KEY` for exchange rates and stock prices, `ONBOARDING_STATE` (`closed`, `invite_only`, `open`).

## Updates

Railway notifies everyone who deployed this template when a change is merged to `main` here, and each deployer chooses when to apply it. Read [`CHANGELOG.md`](CHANGELOG.md) before you apply an update. Database migrations run automatically at the next boot; back up your Postgres data before a major version.

The image is pinned by version and digest. If the upstream registry ever drops this tag, the build fails until the pin is bumped here.

## License

Sure is AGPL-3.0 licensed by its authors. This repository only contains the Railway wrapper.

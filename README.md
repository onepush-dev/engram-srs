# Engram Flashcards (SRS) — self-hosted spaced-repetition flashcards with FSRS scheduling and Anki import. Deploy on Railway with one click.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/ctNG8Q)

[Engram](https://github.com/bestnite/engram) (AGPL-3.0, by bestnite) is a web flashcard app in the spirit of Anki:
decks, note types and card templates, FSRS scheduling with an on-server parameter optimizer, `.apkg` import/export,
media, multi-user accounts with an admin panel, OIDC and an MCP endpoint. (Not related to the "Engram" AI-agent memory
projects.)

This repo wraps the official image `docker.io/nite07/engram:v0.3.0`, binary unmodified, as
`ghcr.io/onepush-dev/engram-srs:v0.3.0`. Railway-only changes (`railway-start.sh`): SQLite and media on the `/data`
volume, Railway's proxy range trusted for client IPs, and on the first boot the administrator is created from
`ENGRAM_ADMIN_PASSWORD` on a loopback-only port before the public port opens, so nobody can claim `/setup`.

## What the template sets up
- One service `engram` on port 8080 with a public domain and a health check on `/healthz`
- A volume at `/data` (`engram.db` SQLite + `media/`)
- Generated per deploy: `ENGRAM_ADMIN_PASSWORD` (sign in as `admin`), `SESSION_SECRET`, `ENCRYPTION_KEY`
  (32-byte base64 key that encrypts stored secrets: keep it). `BASE_URL` follows the Railway domain. No inputs.

## Using it
1. Open the domain and sign in as `admin` with `ENGRAM_ADMIN_PASSWORD` from the service Variables tab.
2. Import an Anki `.apkg` or create a deck, then review. Self-registration is closed by default; invite users or open
   registration in the Admin Panel (SMTP, OIDC and quotas are configured there too).

## Notes
- `ENGRAM_ADMIN_PASSWORD` is used once, on the first boot. Change the password in the app afterwards.
- If you add a custom domain, update `BASE_URL` (used for email links and OIDC redirects).
- Single instance (SQLite). Upstream also supports Postgres via `DB_DRIVER=postgres` and `DB_DSN`.

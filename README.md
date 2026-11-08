# market-correlation-discovery

Analyzing whether tweets from influential people correlate with stock market movements. Includes the data pipeline and database, statistical analysis, and a web app to explore the results.

## Setup

```bash
cp .env.example .env
uv sync --all-packages --all-groups
uv run pre-commit install
make db
make migrate
make dbt-debug
```

## Folders

- `ingestion/` — data ingestion (uv package)
- `db/` — Alembic migrations and schema setup
- `transform/` — dbt project (staging, intermediate, marts)
- `analysis/` — statistical analysis, notebooks and report figures (uv package)
- `backend/` — API for the web app (uv package)
- `frontend/` — web app for exploring results
- `docs/` — project documentation and decision records
- `.github/` — issue and pull request templates

## Repo handling

- `main` is protected. Do not push to it directly; every change goes through a pull request.
- Branch from an up-to-date `main` with a short name, e.g. `feat/…`, `fix/…`, `chore/…`.
- Open a PR with `gh pr create --fill` (or the web UI) and fill in the PR template. Link the issue with `Closes #<n>`.
- The `lint` check from `.github/workflows/ci.yml` must pass before merging. Run `make lint` locally first.
- Use the Task issue template for work items; blank issues are disabled.

### Before you commit (Ruff)

CI runs `make lint`, which only checks (`ruff check` and `ruff format --check`). It never fixes anything, so fix locally first:

```bash
uv run ruff check --fix .   # apply lint fixes
uv run ruff format .        # rewrite formatting
make lint                   # the same check CI runs; must pass
```

`uv run pre-commit install` runs these automatically on commit. Ruff is pinned to the same version in the lockfile and the pre-commit config, so local results match CI.

### Branch protection (one-time, repo admin)

Settings → Branches → Add rule for `main`:

- Require a pull request before merging (0 approvals is fine for a solo repo; raise it once there is a team).
- Require status checks to pass before merging, and select `lint`.
- Require branches to be up to date before merging.
- Do not allow bypassing the above settings.
- Block force pushes and branch deletion.

Or with the GitHub CLI (requires admin rights):

```bash
gh api -X PUT repos/Market-Correlation-Discovery/market-correlation-discovery/branches/main/protection \
  -H "Accept: application/vnd.github+json" \
  --input - <<'JSON'
{
  "required_status_checks": { "strict": true, "contexts": ["lint"] },
  "enforce_admins": true,
  "required_pull_request_reviews": { "required_approving_review_count": 0 },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
```

Note: the `lint` context only appears after the workflow has run at least once on a PR or push to `main`.

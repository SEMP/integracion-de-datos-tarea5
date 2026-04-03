Welcome to your dbt project

Quick start
- Create and activate the venv and install deps:
  - `make install`
  - `source .venv/bin/activate`
- Configure MotherDuck auth (if using MotherDuck):
  - Export your token before running dbt: `source set_env.sh`
- Verify setup:
  - `make debug`

Common commands
- `make run` — runs models (`dbt run --profiles-dir .`)
- `make build` — run + tests (`dbt build --profiles-dir .`)
- `make test` — runs tests only
- `make compile` — compiles models
- `make clean` — removes `.venv/`, `target/`, `logs/`, `dbt_packages/`

Requirements
- Pinned in `requirements.txt` for reproducibility:
  - `dbt-duckdb==1.10.1`
  - `duckdb==1.4.4` (compatible with MotherDuck extension)
  - `python-dotenv==1.2.2` (optional)

Profiles
- This project uses `profiles.yml` in the project root; commands pass `--profiles-dir .`.
- MotherDuck connection in `profiles.yml` expects `MOTHERDUCK_TOKEN` in the environment.

Notes
- Avoid committing secrets: `.gitignore` excludes `.env`, `set_env.sh`, DuckDB files (`*.duckdb*`), and dbt artifacts.
- If you switch to local DuckDB, update `profiles.yml` to use a single `path:` (e.g., `path: local.db`) and remove the MotherDuck extension settings.

Resources
- Learn more about dbt in the docs: https://docs.getdbt.com/docs/introduction
- Community Q&A: https://discourse.getdbt.com/
- Slack: https://community.getdbt.com/
- Events: https://events.getdbt.com
- Blog: https://blog.getdbt.com/

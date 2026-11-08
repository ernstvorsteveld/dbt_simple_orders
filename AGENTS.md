# Agent Rules

## Git & Version Control
- **Never run any `git` commands** (e.g., `git status`, `git diff`, `git add`, `git commit`, `git push`, `git log`, etc.). All version control operations are handled exclusively by the user.

## Installations & File Scope
- **Never install anything outside `/Users/ernstvorsteveld/git/etl/dbt`**. All dependencies, virtual environments (e.g., `.venv`), packages, and configuration files (such as dbt's `profiles.yml`) must stay strictly inside this project directory. Never run global or user-level installs (e.g., `brew`, `pip install --user`, `uv tool install`, global `npm`, etc.) or write files outside this directory (such as `~/.dbt/`).

## Strict Scope & Minimalism
- **Implement ONLY what the user explicitly requests — nothing more.**
- **No scope creep or "helpful" extras:** Never add unrequested error handling, health/readiness checks, environment variable fallbacks, wrapper layers (e.g., Docker wrappers around local commands), logging, summary output, extra CLI flags, extra database/dbt columns, or extra files unless explicitly agreed upon first.
- **Literal, minimal implementation:** Always write the simplest, most direct code that fulfills the exact request.
- **Ask before adding anything:** If a detail is missing or an addition seems useful, ask the user first and wait for agreement before writing it.


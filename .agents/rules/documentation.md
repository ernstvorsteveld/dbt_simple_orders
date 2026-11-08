---
trigger: always_on
---

# Documentation Rules

- **Always add documentation in `docs/`:** Whenever adding or updating services, tools, configurations, data models, or scripts, document them in a dedicated topic file inside `docs/` (for example, `docs/database.md`, `docs/dbt.md`, `docs/data_model.md`) rather than placing detailed sections directly in `README.md`.
- **Keep `README.md` as the central index:** `README.md` must stay a concise project overview with links to every documentation file in `docs/` (`## Documentation`) and every rule file in `AGENTS.md` and `.agents/rules/*.md` (`## Agent Rules`). Whenever a doc or rule file is added, renamed, or removed, update `README.md` accordingly.
- **Required section structure** for anything that is documented:
  1. Start with a concise explanation of what the component/step does and list the available configuration or execution options upfront.
  2. List the default settings/parameters (and any important caveats), when applicable.
  3. Provide concrete code examples for each custom/override option first (e.g., exported environment variables, inline command-line variables, configuration/`.env` files), and place the default command example **last**.

---
name: taylr-sh-pending-edits
description: Docs edits on taylr.sh owed by the 2026-10-27 Phase 1 review; delete this file once they ship
metadata:
  type: project
---

The maintainer decided these in the Phase 1 review; taylr.sh (brightdigit/taylr.sh, under `src/content/docs/docs/`) still shows the old behavior. SPEC and PLAN are already updated.

- `reference/manifest.md` Workflow table: `.ci` → `integration.yml` (was "`app.yml` (`package.yml` in a package)").
- `reference/manifest.md` Build matrix example: `exclude: [.android()]` → `.android(api: 34)`; the API level is required.
- `reference/project.md`: "`.github/workflows/app.yml` runs on pull requests…" → `integration.yml`.
- `cli/project/validate.mdx` sample output: `app.yml, app-store-metadata.yml, …` → `integration.yml, …`.
- `cli/package/validate.mdx` sample output: `package.yml, cleanup, claude` → `integration.yml, cleanup, claude`.

**Why:** the docs are the authority for user-facing behavior, and agents can't change them; until they ship, the code and the docs disagree on purpose.
**How to apply:** treat these two disagreements as decided, not as bugs to report. Delete this memory (and its index line) when taylr.sh has both edits.

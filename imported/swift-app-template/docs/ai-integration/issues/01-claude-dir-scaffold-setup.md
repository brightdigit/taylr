# Foundation: dual-audience config + `setup.sh` staging

**Labels:** `ai-integration`, `setup-script`, `foundation`, `blocker`
**Blocks:** #01b–#12

## Problem

The template repo needs AI-assistant config for **two different audiences at the
same paths**, and today it only serves one:

- **Template developer (you).** Config for maintaining the template itself —
  references `_reference/`, validates `{{TEMPLATE_*}}` placeholders, tests
  `setup.sh`. Should **not** ship to generated apps.
- **End user.** Config for the developer of a generated app — app-dev tooling
  (testing, review, deploy) that **must** ship downstream with tokens replaced.

Currently `setup.sh` treats `.claude/` as throwaway developer content and deletes
it wholesale:

```sh
# Scripts/setup.sh:479-480
# Remove .claude directory (implementation plans)
rm -rf .claude
```

So there is no path by which an end-user `.claude/` reaches a generated app, and
no separation between "yours" and "theirs."

## Key insight: the repo already solves this for docs

`setup.sh` already distinguishes developer vs end-user **documents** via the
`*.template` convention:

```sh
# Scripts/setup.sh:460
mv CLAUDE.template.md CLAUDE.md      # end-user doc promoted over the developer's CLAUDE.md
```

`CLAUDE.md`/`README.md` are the developer's; `CLAUDE.template.md`/
`README.template.md` are the end-user's, promoted at generation time. **This issue
generalizes that same promotion to directories.**

## Proposed change

### 1. Two parallel trees

| Audience | Path | Fate in `setup.sh` |
|---|---|---|
| Template developer | `.claude/` | **removed** (as today) |
| End user | `.claude.template/` | token-replaced, then **promoted** to `.claude/` |

The developer's `.claude/` can hold maintainer tooling (placeholder validation,
`setup.sh` smoke tests, `_reference/` extraction helpers) — out of scope to build
here, but the mechanism must keep it cleanly separate. The end-user
`.claude.template/` holds the shipped skills/agents/commands/hooks from #02–#10.

> The same generalization covers the cross-tool core in #01b
> (`AGENTS.template.md` → `AGENTS.md`) and any future `.cursor.template/`.

### 2. `setup.sh` staging logic

Replace the blanket delete with: token-replace the staged tree, remove the
developer tree, promote the staged tree.

```diff
-# Remove .claude directory (implementation plans)
-rm -rf .claude
+# AI-assistant config: the developer's .claude/ is template-only; the end user's
+# lives in .claude.template/ and is promoted here (mirrors CLAUDE.template.md).
+rm -rf .claude
+if [ -d .claude.template ]; then
+  mv .claude.template .claude
+fi
```

Ensure the existing `{{TEMPLATE_*}}` token-replacement file-walk includes
`.claude.template/` **before** the promotion (so the promoted `.claude/` has the
real app name, Kit package path, fastlane platform, etc.).

### 3. Naming decision

`.claude.template/` is consistent with the existing `CLAUDE.template.md`. A visible
alternative (`claude-template/`, no leading dot) is easier to browse and echoes the
"no dotfiles in template dirs so people can see them" preference — but breaks the
`*.template` symmetry. **Recommend `.claude.template/`** for consistency; call it
out for a quick decision.

### 4. Keep `validate-template.yml` green

- In the **template repo**, `.claude.template/` legitimately contains
  `{{TEMPLATE_*}}` tokens (the validator confirms they're present); the developer's
  `.claude/` must **not** contain template tokens.
- In a **generated repo** (post-setup), no tokens remain under `.claude/` and
  `.claude.template/` no longer exists.
- Confirm the validator's path scope handles `.claude.template/` consistently with
  how it treats `*.template.md`.

### 5. Setup smoke test

Add to the setup integration test: after `setup.sh`,
`.claude/` exists, `.claude.template/` is gone, and
`grep -r '{{TEMPLATE_' .claude` returns nothing.

## Acceptance criteria

- [ ] `.claude.template/` exists in the template, survives as `.claude/` in a
      generated app, and is token-replaced.
- [ ] The developer's `.claude/` is removed by `setup.sh`; the two never collide.
- [ ] After `setup.sh`: `.claude/` present, no `{{TEMPLATE_*}}` tokens,
      `.claude.template/` gone; `validate-template.yml` passes on the template.
- [ ] `setup.sh` cleanup comments updated; mechanism documented for #01b reuse.
- [ ] Naming (`.claude.template/` vs `claude-template/`) decided and recorded.

## References

- `Scripts/setup.sh:460` (`mv CLAUDE.template.md CLAUDE.md`), `:479-480` (delete).
- `.github/workflows/validate-template.yml`.
- Generalized by #01b for `AGENTS.template.md` and per-tool config.

# Package as a plugin + marketplace

**Labels:** `ai-integration`, `plugin`, `distribution`
**Depends on:** #02–#10

## Summary

Bundle the shipped skills, subagents, commands, and hooks into a single
versioned **Claude Code plugin**, distributed via a **marketplace**, so the bundle
can be installed/updated independently of the template copy — and reused across
other BrightDigit Swift repos.

## Motivation

Two distribution paths, not mutually exclusive:

- **Vendored (default).** `.claude/` files copied into each generated repo (issues
  #02–#10). Zero install step; frozen at template-generation time.
- **Plugin (this issue).** The same primitives packaged so downstream repos get
  **versioned updates** without re-running the template, and so the bundle can be
  attached to *existing* Swift repos. This is also the concrete artifact behind the
  "AI-Powered CI with Claude Code" article/workshop topic.

The repo already demonstrates the consumption side: `claude-code-review.yml` uses
`plugin_marketplaces` + `plugins` to pull `code-review@claude-code-plugins`. This
issue produces our own pluggable bundle on the same mechanism.

## Proposed structure

```
swift-app-claude/                      # the plugin (in-repo or own repo)
├── .claude-plugin/
│   └── plugin.json
├── skills/        swift-testing/, swift-feature/, tuist-project/
├── agents/        swift-test-writer.md, swift-reviewer.md, ci-triage.md
├── commands/      generate.md, lint.md, test.md, beta.md, certs.md
└── hooks/         hooks.json
```

`plugin.json`:

```json
{
  "name": "swift-app-claude",
  "description": "AI-dev primitives for Tuist + Fastlane Swift apps (testing, review, CI triage, deploy).",
  "version": "0.1.0",
  "author": { "name": "BrightDigit" },
  "license": "MIT"
}
```

Marketplace entry (`marketplace.json` — in-repo or a dedicated
`brightdigit/swift-claude-plugins` repo):

```json
{
  "name": "brightdigit",
  "owner": { "name": "BrightDigit" },
  "plugins": [
    { "name": "swift-app-claude", "source": "github",
      "owner": "brightdigit", "repo": "Swift-App-Template", "path": "swift-app-claude" }
  ]
}
```

### Wire into the GitHub workflows

Update `claude.yml` (and optionally `claude-code-review.yml`) to load it:

```yaml
plugin_marketplaces: 'https://github.com/brightdigit/Swift-App-Template.git'
plugins: 'swift-app-claude@brightdigit'
```

## Open design questions

- [ ] **Plugin tokens.** Plugin files are *not* run through `setup.sh` token
      replacement if the plugin lives in its own repo. Either (a) make the plugin
      app-agnostic (derive the Kit package path at runtime, e.g. glob
      `Packages/*Kit`) or (b) keep app-specific bits in the vendored `.claude/` and
      ship only app-agnostic primitives in the plugin. **Recommend (a)** so one
      plugin serves every generated app.
- [ ] **Single source of truth.** Avoid divergence between vendored `.claude/` and
      the plugin — generate one from the other, or pick the plugin as canonical and
      have `setup.sh` reference it instead of copying files.
- [ ] **Location.** Plugin inside this repo (simplest) vs separate repo (cleaner
      versioning, reusable across the 128+ repos referenced in the content series).

## Acceptance criteria

- [ ] `/plugin install swift-app-claude@brightdigit` (or `--plugin-dir`) loads all
      skills/agents/commands/hooks.
- [ ] Plugin primitives are app-name-agnostic (no `{{TEMPLATE_*}}`, no hardcoded
      app name) OR the app-specific/app-agnostic split is documented.
- [ ] `claude.yml` updated to pull the plugin; an `@claude` run can use a shipped
      skill from the plugin.
- [ ] Versioning/update story documented in #12.

## References

- Existing `claude-code-review.yml` (`plugin_marketplaces`/`plugins` pattern).
- [Plugins](https://code.claude.com/docs/en/plugins.md) ·
  [Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces.md) ·
  [GitHub Action](https://code.claude.com/docs/en/github-actions.md)

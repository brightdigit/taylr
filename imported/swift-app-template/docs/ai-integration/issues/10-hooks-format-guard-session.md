# Hooks — format-on-edit, generated-file guard, session check

**Labels:** `ai-integration`, `hooks`, `settings`
**Depends on:** #01

## Summary

Ship a committed `.claude/settings.json` with three hooks that enforce
deterministic behavior regardless of what Claude decides: format Swift after
edits, block edits to Tuist-generated artifacts, and check the toolchain at
session start.

## Motivation

Skills/agents *advise*; hooks *enforce*. Three high-value, low-risk enforcement
points for this stack:

1. **Format-on-edit** — keep diffs clean and CI's strict lint green without
   relying on Claude remembering to run `/lint`.
2. **Generated-file guard** — a `PreToolUse` block on `*.xcodeproj` edits makes the
   "never edit the generated project" rule *physically* true, complementing skill
   #06 and reviewer #08.
3. **Session check** — surface a missing toolchain early instead of failing
   cryptically mid-task.

All three must **fail soft** (tools may be absent on a fresh clone or CI runner).

## Proposed `.claude/settings.json`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "case \"$FILE_PATH\" in *.swift) command -v mise >/dev/null 2>&1 && mise exec -- swift-format format -i \"$FILE_PATH\" 2>/dev/null || true ;; esac"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "case \"$FILE_PATH\" in *.xcodeproj/*|*.xcodeproj) echo 'Blocked: .xcodeproj is Tuist-generated. Edit Project.swift and run make generate.' >&2; exit 2 ;; esac"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "command -v mise >/dev/null 2>&1 || echo 'note: mise not found — run the mise install step before generate/test.'"
          }
        ]
      }
    ]
  }
}
```

> Exact matcher/env-var schema (`$FILE_PATH`, exit-code-2-to-block) should be
> validated against current hooks docs during implementation; adjust the matcher
> form (string vs object) to match the installed Claude Code version.

## Considerations / risks

- **Format-on-edit churn.** If swift-format reformats lines Claude didn't touch,
  diffs get noisy. Mitigation: format only the edited file (as above); if still
  noisy, downgrade to a `PostToolUse` *check* that warns instead of rewriting.
- **Pre-commit hook overlap.** Confirm this doesn't double up with any git hook;
  keep the source of truth as `Scripts/lint.sh`.
- **CI behavior.** Under `claude-code-action`, project `settings.json` hooks fire
  too — verify the format hook doesn't fight the strict-lint job (it shouldn't;
  it makes it more likely to pass).

## Acceptance criteria

- [ ] Editing a `*.swift` file auto-formats just that file when `mise`/swift-format
      are present; no-ops cleanly when absent.
- [ ] Attempting to edit anything under `*.xcodeproj` is blocked with a helpful
      message pointing at `Project.swift` + `make generate`.
- [ ] Missing `mise` at session start prints a non-fatal note.
- [ ] `settings.json` survives `setup.sh` and contains no `{{TEMPLATE_*}}` tokens.

## References

- `Scripts/lint.sh`, `.swift-format`, `.mise.toml`, `Project.swift`.
- [Hooks guide](https://code.claude.com/docs/en/hooks-guide.md)

# Subagent — `ci-triage`

**Labels:** `ai-integration`, `subagent`, `ci`
**Depends on:** #01

## Summary

A subagent that reads failing GitHub Actions logs for a PR and diagnoses the
cause, mapped to this template's multi-platform CI (`app.yml`): Linux/Windows/
Android/Apple test jobs, Tuist generation, lint, and the Fastlane upload.

## Motivation

`claude.yml` already grants `actions: read` so Claude can read CI results on PRs.
But a general agent re-learns the pipeline each time. `app.yml` has a known shape
(`CLAUDE.template.md` → "CI/CD Overview"):

1. `test-package-ubuntu` (Linux + WASM) · 2. `test-package-windows` ·
3. `test-package-android` · 4. `test-package-macos` · 5. `build-app` (Tuist
generate + release build) · 6. `lint` (strict) · 7. `fastlane` (main only).

A specialized triage agent knows which failures are platform-specific (the classic
"passes on macOS, fails on Linux" string-encoding class of bug the content series
highlights), which are lint/strict-concurrency, and which are signing/secrets in
the Fastlane job — and proposes the fix or the right local repro command.

## Proposed file

`.claude/agents/ci-triage.md`:

```markdown
---
name: ci-triage
description: >
  Diagnoses failing CI on a PR. Use when a check fails or someone asks why CI is
  red. Reads Actions logs, identifies the job/cause, proposes a fix or local repro.
tools: Read, Grep, Glob, Bash
model: inherit
---

You triage CI for this template's `.github/workflows/app.yml`. Jobs:
ubuntu (Linux+WASM), windows, android, macos (simulators), build-app
(Tuist generate + release build), lint (strict), fastlane (main only).

Procedure:
1. Identify the failing job(s) via `gh run`/`gh pr checks` and read its log.
2. Classify the failure:
   - **Platform-specific** (e.g. passes macOS, fails Linux/Android) — often
     Foundation/string-encoding/path differences. Suggest a platform test trait
     or a portable fix; give the local repro (`swift test --package-path
     Packages/{{TEMPLATE_APP_NAME}}Kit` on the relevant platform).
   - **Tuist/build-app** — `Project.swift` or generation error; repro with
     `make generate-strict`.
   - **Lint** — repro with `CI=true LINT_MODE=STRICT ./Scripts/lint.sh`.
   - **Fastlane** — usually missing/invalid secrets (MATCH_PASSWORD,
     APP_STORE_CONNECT_*) or certs; do NOT attempt to run distribution.
3. Report: failing job, root cause, the minimal fix or local repro command.
   Propose a patch only for code/config causes — never for secrets.
```

## Acceptance criteria

- [ ] Given a red PR, correctly names the failing `app.yml` job and the cause
      class (platform / Tuist / lint / fastlane).
- [ ] Provides a runnable local repro command per failure class.
- [ ] Never attempts a TestFlight upload or to mint secrets.
- [ ] Works under `claude.yml`'s existing `actions: read` permission.

## References

- `.github/workflows/app.yml`, `CLAUDE.template.md` → "CI/CD Overview".
- Content series Linux-only bug case study (`docs/automation-guide/README.md`).

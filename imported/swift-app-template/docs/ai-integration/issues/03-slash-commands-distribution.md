# Slash commands — distribution (`/beta`, `/certs`)

**Labels:** `ai-integration`, `slash-command`, `fastlane`, `needs-safety-review`
**Depends on:** #01

## Summary

Ship two user-invoked commands for the Fastlane side of the workflow — TestFlight
upload and certificate sync. These are **outward-facing and credential-sensitive**,
so they are explicitly designed to *explain and confirm*, not auto-run.

## Motivation

`make beta` and `make certs` are the highest-stakes commands in a generated repo:
they touch App Store Connect, rewrite the certificates repo, and consume secrets
from `.env`. A developer benefits from a command that lays out preconditions
(secrets present, certs synced, correct lane for the platform) before anything
runs. This is real procedural value, not an alias.

## Safety model (important)

- `disable-model-invocation: true` on both — **never** auto-invoked by Claude;
  only a human typing `/beta` or `/certs` triggers them.
- The command body instructs Claude to **stop and confirm** before executing the
  outward-facing step, and to verify `.env` / required secrets first.
- These commands are most useful **locally**; in CI the Fastlane lane runs via the
  existing `app.yml` job, not via `@claude`.

## Proposed files

`.claude/commands/beta.md`:

```markdown
---
description: Build and upload a TestFlight beta via Fastlane. Outward-facing — confirm before running.
disable-model-invocation: true
---
Ship a TestFlight beta with `make beta` (Fastlane `beta` lane).

Before running, verify and report:
1. `.env` has the App Store Connect API key vars (see `.env.example`):
   APP_STORE_CONNECT_API_KEY_ID / _ISSUER_ID / _KEY_CONTENT.
2. Certificates are available (`make certs` has been run) and `MATCH_PASSWORD` is set.
3. The working tree is clean and on the intended branch.

This uploads to App Store Connect and is hard to reverse. **Ask for explicit
confirmation before executing `make beta`.** $ARGUMENTS
```

`.claude/commands/certs.md`:

```markdown
---
description: Sync code-signing certificates via Fastlane Match. Modifies the certs repo.
disable-model-invocation: true
---
Sync certificates with Fastlane Match:

- All: `make certs`
- Development only: `make certs-dev`
- App Store only: `make certs-appstore`

Regenerate variants (`make certs-regenerate*`) **revoke and recreate** certs and
can break other machines/CI — only on explicit request, and confirm first.
Requires `MATCH_PASSWORD` and access to the certs repo
(`{{TEMPLATE_CERTS_REPO}}`). $ARGUMENTS
```

## Acceptance criteria

- [ ] Both commands carry `disable-model-invocation: true` and a confirm-before-run
      instruction for the outward-facing step.
- [ ] After `setup.sh`, `/certs` references the real certs repo (no token).
- [ ] Commands enumerate the required `.env`/secret preconditions before acting.
- [ ] Regenerate/destructive variants are gated behind explicit user request.

## References

- Make targets: `Makefile` (`beta`, `certs`, `certs-dev`, `certs-appstore`,
  `certs-regenerate*`).
- `.env.example`, `fastlane/` (Fastfile, Matchfile, Appfile).
- Memory: `push-lumemo force-push` precedent shows some scripts are intentionally
  history-rewriting; certs-regenerate is similarly intentional but still gated.

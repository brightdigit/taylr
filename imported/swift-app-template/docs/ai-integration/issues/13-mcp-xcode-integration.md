# MCP integration — give the assistant live Xcode state

**Labels:** `ai-integration`, `mcp`, `xcode`, `enhancement`
**Depends on:** #01
**Related:** #09 (ci-triage), #01c

## Summary

Document (and optionally pre-configure) Model Context Protocol servers so the
assistant in a generated app can reach **live build/test/diagnostic state** —
turning skills/subagents from "reason about files" into "see what the compiler and
simulator actually report."

## Motivation

Skills and `AGENTS.md` make the assistant *knowledgeable*; MCP makes it
*situationally aware*. For a Swift app the high-value servers are:

- **`xcrun mcpbridge` (official Apple).** Turns Xcode itself into an MCP host over
  XPC: structured build/test results, diagnostics, file ops, Swift REPL, headless
  SwiftUI previews. Shipped in Xcode 26.3, carried into 27. This is the strategic
  center — Apple owns it, we just wire it.
- **XcodeBuildMCP (community, MIT, Sentry-maintained).** build, simulators, device
  install/launch, log capture, tests, UI automation. Works on older Xcode too.
- **ios-simulator-mcp (community, MIT).** tap/swipe/type, accessibility tree,
  screenshots, video of the simulator.

This directly upgrades the `ci-triage` subagent (#09) and the built-in `verify`/
`run` skills: instead of parsing logs, the assistant queries real diagnostics.

## Proposed change

### 1. Document the official bridge (primary)

In the generated README / `AGENTS.md`, document enabling Xcode's MCP host and
wiring Claude Code to it (verify exact command on a real Xcode 27 machine):

```
# Xcode: Settings → Intelligence → "Allow external agents to use Xcode tools"
claude mcp add --transport stdio xcode -- xcrun mcpbridge
```

### 2. Optionally ship a commented `.mcp.json`

Ship an opt-in, commented MCP config in `.claude.template/` listing the community
servers so users uncomment what they want (none enabled by default — they pull
external code):

```jsonc
// .claude/.mcp.json — optional Swift dev MCP servers (uncomment to enable)
{
  "mcpServers": {
    // "xcodebuild": { "command": "npx", "args": ["-y", "xcodebuildmcp@latest"] },
    // "ios-simulator": { "command": "npx", "args": ["-y", "ios-simulator-mcp"] }
  }
}
```

### 3. Caveats to document

- `xcrun mcpbridge` requires Xcode 26.3+/27 and Apple Silicon + macOS 26.4.
- Community servers pull external code (npx) — opt-in, pin versions, note licenses
  (both MIT).
- MCP servers are not auto-loaded by `claude-code-action` in CI unless configured;
  these are primarily a local-dev enhancement.

## Acceptance criteria

- [ ] Generated README/`AGENTS.md` documents wiring `xcrun mcpbridge` (with the
      platform requirement and the verify-the-command caveat).
- [ ] Optional commented `.mcp.json` ships (all servers disabled by default) and
      survives `setup.sh`.
- [ ] `ci-triage` (#09) notes it can use Xcode MCP diagnostics when available.

## References

- Apple: "Giving external agents access to Xcode"
  (`developer.apple.com/documentation/xcode/giving-external-agents-access-to-xcode`).
- [XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP) ·
  [ios-simulator-mcp](https://github.com/joshuayoes/ios-simulator-mcp)
- [MCP docs](https://code.claude.com/docs/en/mcp.md)

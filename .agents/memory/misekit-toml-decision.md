---
name: misekit-toml-decision
description: Decided 2026-10-27: MiseKit gets its own minimal TOML decoder; fork dduan/TOMLDecoder or write a full one only if that falls short
metadata:
  type: project
---

Decided by the maintainer on 2026-10-27 (tabled since 2026-10-26): MiseKit reads TOML back with **its own minimal decoder**, matching its own minimal encoder. No dependency.

PLAN 2.2 says MiseKit has its own minimal TOML encoder and no dependency. SPEC (line 108, and `validate`) needs encode → decode → equal tests and decoding the on-disk `.mise.toml`, so an encoder alone was not enough.

If the minimal decoder falls short (for example, hand-edited `.mise.toml` files using TOML outside the subset taylr writes), the fallback is to fork dduan/TOMLDecoder or write a fuller decoder. LebJe/TOMLKit was ruled out: it wraps C++ toml++.

**Why:** keeps MiseKit dependency-free and symmetric with its encoder; the plan and spec agree once the decoder exists.
**How to apply:** build the decoder for the same subset the encoder writes (strings, booleans, integers, arrays, inline tables, `[section]` tables), with a clear error for anything else. Raise the fallback with the maintainer when a real file needs more; don't add a TOML dependency without asking.

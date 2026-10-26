---
name: misekit-toml-decision
description: Open, tabled decision on how MiseKit decodes TOML; the plan says encoder-only but the spec needs round-trip
metadata:
  type: project
---

Tabled by the maintainer on 2026-10-26: how MiseKit reads TOML back.

PLAN 2.2 says MiseKit has its own minimal TOML encoder and no dependency. SPEC (line 108, and `validate`) needs encode → decode → equal tests and decoding the on-disk `.mise.toml`, so an encoder alone is not enough.

Options on the table:
1. A matching minimal decoder in MiseKit (no dependency; may reject hand-edited files outside the subset).
2. Own encoder plus a pure-Swift decode-only dependency such as dduan/TOMLDecoder (needs approval).
3. LebJe/TOMLKit (encode and decode, but wraps C++ toml++).

**Why:** the plan and spec disagree, and adding a dependency needs the maintainer's approval.
**How to apply:** do not build MiseKit's decoding (plan step 2.2 round-trip) until the maintainer picks an option; ask when that step comes up.

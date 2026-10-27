---
name: manifest-loading
description: Why taylr reads Manifest.swift as JSON from a compiled child process, and the alternatives ruled out
metadata:
  type: project
---

`Manifest.swift` is user source code, and Swift has no `eval`, so taylr compiles it (plus a one-line driver `main.swift` calling `ManifestJSON.write(manifest)`) against `TaylrDescription`, runs the binary, and decodes its stdout with `ManifestJSON.manifest(from:)`. Same pattern as SwiftPM's `Package.swift` and Tuist's `Project.swift`. The #17 test `ManifestCompiler` does this for every docs example; Phase 4.3's `ManifestLoader` does it for real and caches by file hash under `.build/taylr/`.

Ruled out (2026-10-27 review):
- `dlopen` of a compiled dylib: the dylib carries its own `TaylrDescription` copy, so its types aren't taylr's; user-code crashes would crash taylr; no version boundary.
- Parsing with SwiftSyntax: would need a Swift interpreter for constants like `let models = Package(...)`.

**Why:** the JSON only ever passes between taylr and the compiled manifest, so its shape (synthesized `_0` keys today) doesn't matter to users; #118 cleans it up with the protocol model.
**How to apply:** don't propose in-process loading or JSON-shape cosmetics for their own sake; any manifest type must survive `ManifestJSON` encode/decode.

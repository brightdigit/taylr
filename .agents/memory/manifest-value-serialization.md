# Manifest values and their serialization

**Decision (2026-10-27, review of #104):** every manifest concept with associated values is a protocol that refines `ManifestValue` and pins its `Serialization` associated type to one enum named `<Concept>Serialization` (`Header` → `HeaderSerialization`). Concrete structs conform (`FileHeader`); the docs spellings come from `extension Header where Self == FileHeader { static func file(_:) }`. Models store the serialization enum, not the protocol value.

**Why:** the maintainer wanted SwiftUI-style protocols (like `ButtonStyle`) without losing synthesized `Equatable` and `Codable` or hand-writing `==`. Storing the serialization, the way SwiftPM's PackageDescription serializes its manifest, keeps both synthesized and gives labeled JSON keys. The enum's cases are the closed set TaylrKit switches over, so no type registry is needed.

**Compiler facts (Swift 6.4.1, checked in `swift:6.4-resolute`):**
- A type cannot be nested in a protocol (`type 'X' cannot be nested in protocol 'Header'`), so `Header.Serialization` as a nested enum is impossible.
- `Header.Serialization` cannot name the pinned associated type outside a generic context (`cannot access associated type 'Serialization' from 'Header'`).
- `(some Header)? = .file(…)` does not infer the generic parameter; `(any Header)? = .file(…)` works, as do `.file("a")`, `nil` and the default at call sites.
- `#expect` blocks implicit opening of an existential; open it outside the macro.

**How to apply:** the maintainer chose `HeaderSerialization` over a `Serialization.Header` namespace. Name new serialization enums `<Concept>Serialization`, give every associated value a label, and add a test that the JSON uses those labels.

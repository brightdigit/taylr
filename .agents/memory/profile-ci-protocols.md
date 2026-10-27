# Profile and CI as protocols

**Decision (2026-10-27, maintainer):** `Profile` became the `ProfileSource` protocol with two conforming types: `ProfileReference` (`.named("client-x")`) and `CustomProfile` (`.custom(organization: …)`, the inline profile). Models store `ProfileSerialization` (`reference(name:)`, `custom(profile:)`). `CI` became a protocol with one conforming type, `GitHubActions`; its `Workflow`, `Matrix`, `Runners` and `MatrixEntry` moved under `GitHubActions`, because Swift can't nest types in a protocol.

**Why `.custom`:** an implicit `.init(…)` cannot resolve against an existential (`'any ProfileSource' cannot be constructed`), so the docs' `profile: .init(organization: …)` can't compile. The maintainer chose the static `.custom(…)` over overloading every `App` init.

**Pending docs edit (taylr.sh `reference/manifest.md`, Profile section):** `profile: .init(organization: …)` → `profile: .custom(organization: …)`. Not made here: the docs are the maintainer's to change.

**Compiler bug (Swift 6.4.1):** `existentials.map(\.serialization)` over `[any P]` crashes SILGen (`emitKeyPathComponentForDecl`). Use `map { $0.serialization }`.

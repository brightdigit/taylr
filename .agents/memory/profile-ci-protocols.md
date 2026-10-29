# Profile and CI as protocols

**Decision (2026-10-27, maintainer):** `Profile` became the `ProfileSource` protocol with two conforming types: `ProfileReference` (`.named("client-x")`) and `CustomProfile` (`.organization("Client X Inc", …)`, the inline profile). Models store `ProfileSerialization` (`reference(name:)`, `custom(profile:)`). `CI` became a protocol with one conforming type, `GitHubActions`; its `Workflow`, `Matrix`, `Runners` and `MatrixEntry` moved under `GitHubActions`, because Swift can't nest types in a protocol.

**Why `.organization`:** an implicit `.init(…)` cannot resolve against an existential (`'any ProfileSource' cannot be constructed`), so the docs' `profile: .init(organization: …)` can't compile. The maintainer chose a static over overloading every `App` init, and named it `.organization(_:…)` after the one required field (not `.custom`).

**Pending docs edit (taylr.sh `reference/manifest.md`, Profile section):** `profile: .init(organization: …)` → `profile: .organization("Client X Inc", …)`. Not made here: the docs are the maintainer's to change.

**Compiler bug (Swift 6.4.1):** `existentials.map(\.serialization)` over `[any P]` crashes SILGen (`emitKeyPathComponentForDecl`). Use `map { $0.serialization }`.

**Root types for shared concepts (2026-10-29, maintainer):** the profile parts are top-level types, not nested under `CustomProfile`, so named profiles and later features can share them: `AppleTeam` (was `CustomProfile.Apple`), `Signing`, `Storage`/`StorageSerialization` with `GitStorage`, `S3Storage`, `GoogleCloudStorage`, `GitLabSecureFilesStorage`, `Secrets`/`SecretsSerialization` with `TeamSecrets`, `ProfileSecrets`, `EnvironmentSecrets`, `GitHubOrganization`, and `CISecretsSharing` (was `GitHubOrganization.CISecrets`). GitHub-only CI types stay under `GitHubActions` (including `Matrix.Entries`). Leading-dot spellings and encoded data are unchanged.

**Deferred:** a `ManifestValue` type has one `Serialization`, so a backend can't conform to two concepts with different enums. When a storage backend gets a second use with different needs, split it into a root location type (e.g. `GoogleCloud`, holding bucket/project/prefix) with an inner type per use (`GoogleCloud.Signing`, `GoogleCloud.Artifacts`). Don't build it before that happens.

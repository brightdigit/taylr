# Imported: Swift-App-Template

`swift-app-template/` is a copy of `private/taylr/` from brightdigit/Swift-App-Template@2653ede, taken before that folder was deleted (brightdigit/taylr#176). It's the content reference that `.agents/SPEC.md` and `.agents/PLAN.md` point to: the TemplateGenerator package (PLAN 3.2), the generated-app template (3.3/3.4) and resources such as fastlane, Gemfile, Makefile, Dockerfile and scripts (3.7).

This folder lives only on this branch. Each piece gets integrated into Taylr or deleted before this branch merges to `main`. SwiftLint skips it (see `.swiftlint.yml`).

- `swift-app-template/template/`: the generated-app template (`{{TEMPLATE_*}}` placeholders)
- `swift-app-template/Scripts/`: `setup.sh` and helper scripts
- `swift-app-template/docs/decisions/`: ADR 0001, which `.agents/SPEC.md` cites
- `swift-app-template/docs/ai-integration/`: already imported as issues #135–#152

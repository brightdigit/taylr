# ``TaylrDescription``

Manifest.swift: your project's settings, checked by the compiler.

## Overview

`taylr project create` and `taylr package create` write `Manifest.swift` at the root of the
project. It records your answers: the name, the platforms, the GitHub and CI setup, the tools and
files the project has and, for an app, its profile, web links and packages.

It's Swift, like Tuist's `Project.swift`. It builds one value from this module, so the compiler
checks every field: an ``App`` in an app, a ``Package`` in a Swift package. Optional arguments
have defaults, so leave out anything you don't need. `create` does the same: it only writes a
value that differs from its default, whether it came from a question, an argument or your
profile.

Commit it. Check it's in sync with the project with `taylr project validate` or
`taylr package validate`. What the compiler can't check, such as a misspelled package name,
`validate` reports.

### An app with a server

```swift
import TaylrDescription

let manifest = App(
  name: "Acme",
  profile: .named("default"),
  platforms: [.iOS(), .macOS()],
  urls: .base("https://acme.example"),
  server: .server(framework: .hummingbird(routing: .openAPI))
)
```

With the `default` profile's bundle ID prefix `com.acmecorp`, the bundle ID is
`com.acmecorp.Acme` and the app group is `group.com.acmecorp.Acme`.

### An iPhone and iPad app that needs iOS 27.2

This app has no server, and its web links aren't decided yet:

```swift
let manifest = App(
  name: "Acme",
  profile: .named("default"),
  platforms: [.iOS("27.2")]
)
```

### A Swift package

```swift
let manifest = Package(
  name: "Acme",
  platforms: [.iOS(), .macOS(), .visionOS()]
)
```

An open-source package that also builds with older Swift, on GitHub's runners, with Periphery
too:

```swift
let manifest = Package(
  name: "AcmeCharts",
  platforms: [.iOS(), .macOS()],
  swiftVersion: "6.1",
  includeNightly: true,
  github: .init(repository: "acme/AcmeCharts"),
  ci: .githubActions(runners: .githubHosted),
  lint: [.swiftLint, .swiftFormat, .periphery],
  license: .apache2
)
```

### How taylr reads the manifest

taylr compiles `Manifest.swift` with a driver that calls ``ManifestJSON/write(_:)-(Manifest)`` and
runs it. The binary prints the manifest as JSON, which taylr decodes into a ``Manifest``.

## Topics

### The manifest

- ``Manifest``
- ``ManifestJSON``

### An app

- ``App``
- ``Profile``
- ``URLs``
- ``Packages``
- ``AppStoreConnect``
- ``Screenshots``
- ``Distribution``
- ``PressKit``
- ``Generator``

### A Swift package

- ``Package``
- ``Dependency``
- ``DependencyConvertible``
- ``ServerFramework``

### Platforms

- ``Platform``
- ``PlatformVersion``

### Settings for every project

- ``GitHub``
- ``CI``
- ``LintTool``
- ``Header``
- ``License``
- ``Agent``

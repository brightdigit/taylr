fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Mac

### mac setup_app

```sh
[bundle exec] fastlane mac setup_app
```

Register app in Apple Developer Portal and App Store Connect

### mac sync_certificates_development

```sh
[bundle exec] fastlane mac sync_certificates_development
```

Sync development certificates and provisioning profiles

### mac regenerate_development_profiles

```sh
[bundle exec] fastlane mac regenerate_development_profiles
```

Force regenerate development provisioning profiles with updated capabilities

### mac sync_certificates_appstore

```sh
[bundle exec] fastlane mac sync_certificates_appstore
```

Sync App Store certificates and provisioning profiles

### mac regenerate_appstore_profiles

```sh
[bundle exec] fastlane mac regenerate_appstore_profiles
```

Force regenerate App Store provisioning profiles with updated capabilities

### mac regenerate_all_profiles

```sh
[bundle exec] fastlane mac regenerate_all_profiles
```

Force regenerate all provisioning profiles (development and appstore)

### mac sync_certificates

```sh
[bundle exec] fastlane mac sync_certificates
```

Sync all certificates (development and appstore)

### mac test

```sh
[bundle exec] fastlane mac test
```

Run all unit tests

### mac build

```sh
[bundle exec] fastlane mac build
```

Build debug version

### mac release_build

```sh
[bundle exec] fastlane mac release_build
```

Build release version for App Store

### mac screenshot

```sh
[bundle exec] fastlane mac screenshot
```

Capture screenshots for App Store

### mac beta_test

```sh
[bundle exec] fastlane mac beta_test
```

Build release package for TestFlight (no upload)

### mac beta

```sh
[bundle exec] fastlane mac beta
```

Upload to TestFlight for beta testing

### mac release

```sh
[bundle exec] fastlane mac release
```

Deploy to App Store

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

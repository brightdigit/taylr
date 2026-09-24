fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

Lanes run under the platform set by `PLATFORM` in `fastlane/.env.default`, so the platform prefix can be omitted.

### setup_app

```sh
[bundle exec] fastlane setup_app
```

Register app in Apple Developer Portal and App Store Connect

### sync_certificates_development

```sh
[bundle exec] fastlane sync_certificates_development
```

Sync development certificates and provisioning profiles

### regenerate_development_profiles

```sh
[bundle exec] fastlane regenerate_development_profiles
```

Force regenerate development provisioning profiles with updated capabilities

### sync_certificates_appstore

```sh
[bundle exec] fastlane sync_certificates_appstore
```

Sync App Store certificates and provisioning profiles

### regenerate_appstore_profiles

```sh
[bundle exec] fastlane regenerate_appstore_profiles
```

Force regenerate App Store provisioning profiles with updated capabilities

### regenerate_all_profiles

```sh
[bundle exec] fastlane regenerate_all_profiles
```

Force regenerate all provisioning profiles (development and appstore)

### sync_certificates

```sh
[bundle exec] fastlane sync_certificates
```

Sync all certificates (development and appstore)

### test

```sh
[bundle exec] fastlane test
```

Run all unit tests

### build

```sh
[bundle exec] fastlane build
```

Build debug version

### release_build

```sh
[bundle exec] fastlane release_build
```

Build release version for App Store

### sync_build_number

```sh
[bundle exec] fastlane sync_build_number
```

Set CURRENT_PROJECT_VERSION from latest TestFlight build + 1

### screenshot

```sh
[bundle exec] fastlane screenshot
```

Capture screenshots for App Store

### beta

```sh
[bundle exec] fastlane beta
```

Upload to TestFlight for beta testing

### release

```sh
[bundle exec] fastlane release
```

Deploy to App Store

### upload_metadata

```sh
[bundle exec] fastlane upload_metadata
```

Upload metadata and screenshots without a binary

### upload_privacy_details

```sh
[bundle exec] fastlane upload_privacy_details
```

Upload App Privacy nutrition labels (no data collected)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

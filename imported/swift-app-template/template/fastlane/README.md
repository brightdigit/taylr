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

### setup_groups

```sh
[bundle exec] fastlane setup_groups
```

Create the App Group identifier and associate it with the App ID

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

### add_dev_device

```sh
[bundle exec] fastlane add_dev_device
```

Usage: fastlane add_dev_device udid:<device-udid> name:"My iPhone"

### nuke_development_certs

```sh
[bundle exec] fastlane nuke_development_certs
```

Revoke and delete the shared development certificate + profiles (team-wide)

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

### capture_ios

```sh
[bundle exec] fastlane capture_ios
```

Capture App Store screenshots using snapshot (settings in fastlane/Snapfile)

### capture_frame

```sh
[bundle exec] fastlane capture_frame
```

Frame screenshots with device bezels and marketing text

### capture_all

```sh
[bundle exec] fastlane capture_all
```

Capture all screenshots and frame them

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

Metadata only — the binary is uploaded separately by the `beta` lane.

### upload_privacy_details

```sh
[bundle exec] fastlane upload_privacy_details
```

Upload App Privacy nutrition labels from fastlane/app_privacy_details.json

### sync_featuring_nomination

```sh
[bundle exec] fastlane sync_featuring_nomination
```

Options: file:path, name:<file name>, dry_run:true, submit:true (human editorial submit)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

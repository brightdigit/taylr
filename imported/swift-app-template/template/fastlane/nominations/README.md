# Featuring nominations

Version-controlled App Store **Featuring Nomination** copy. A nomination asks
Apple Editorial to consider the app for featuring around a launch, a major
update, or new content.

`deliver` / `upload_metadata` do **not** manage Featuring Nominations. YAML files
in this folder are the source of truth; `sync_featuring_nomination` pushes them
to the [App Store Connect Nominations API](https://developer.apple.com/documentation/appstoreconnectapi)
(`POST`/`PATCH /v1/nominations`).

## Example

Save as e.g. `fastlane/nominations/v1.0.0.yml`:

```yaml
# Omit nomination_id to create a new nomination; the lane prints the new id —
# write it back here so re-runs update the same draft.
# nomination_id: "00000000-0000-0000-0000-000000000000"
name: "v1.0.0 launch"
type: APP_LAUNCH            # APP_LAUNCH / APP_ENHANCEMENTS / NEW_CONTENT

publish_window:
  start: "2026-10-01"       # ISO-8601 date or date-time
  end: "2026-10-15"
  timezone: "UTC"           # used for date-only values (UTC, EST/EDT, PST/PDT)

device_families:            # IPHONE, IPAD, MAC, APPLE_TV, APPLE_VISION_PRO, APPLE_WATCH
  - IPHONE

locales:                    # match your fastlane/metadata locales
  - EN-US

related_apps: []            # empty → this app's App Store Connect id

launch_certain_markets_first: false
new_in_app_event: false
includes_preorder: false

supplemental_materials:
  - "https://example.com/press"

description: |
  What the app does and why it's a great fit for featuring.

helpful_details: |
  Anything else Editorial should know (ASC field: notes).
```

## Field reference

| Field | YAML key | ASC / API |
|---|---|---|
| Nomination ID | `nomination_id` | resource id (omit to create) |
| Name | `name` | `name` |
| Type | `type` | `APP_LAUNCH` / `APP_ENHANCEMENTS` / `NEW_CONTENT` |
| Publish window | `publish_window.start/end/timezone` | `publishStartDate` / `publishEndDate` |
| Platforms | `device_families` | `deviceFamilies` |
| Locales | `locales` | uppercased (`EN-US`, `JA`, …) |
| Description | `description` | `description` |
| Helpful details | `helpful_details` | `notes` |
| Supplemental URLs | `supplemental_materials` | `supplementalMaterialsUris` |
| Flags | `launch_certain_markets_first`, `new_in_app_event`, `includes_preorder` | matching booleans |
| Related apps | `related_apps` | empty → this app's ASC id on create |

## Sync

```sh
# With a single YAML file in this folder
make sync-featuring-nomination

# Preview the payload without writing
bundle exec fastlane sync_featuring_nomination dry_run:true

# Pick a file when there are several
bundle exec fastlane sync_featuring_nomination name:v1.0.0
```

Requires the App Store Connect API key env vars
(`APP_STORE_CONNECT_API_KEY_KEY_ID`, `…_ISSUER_ID`, `…_KEY`) with at least the
App Manager role.

## Submitting stays a human step

- Default sync keeps drafts as drafts (`submitted: false`).
- If the nomination is already `SUBMITTED`, sync refreshes editable fields and
  sends `submitted: true` only because ASC requires it to keep that state.
- Once submitted, ASC locks **type** and **related apps**.
- To deliberately submit a draft via the API (prefer the ASC UI for timing):
  `bundle exec fastlane sync_featuring_nomination submit:true`

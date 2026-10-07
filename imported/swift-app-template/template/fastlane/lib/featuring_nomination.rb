# frozen_string_literal: true

require "yaml"
require "time"

# Sync App Store Featuring Nominations from YAML via the ASC Nominations API
# (`/v1/nominations`). Spaceship has no Nomination model yet; we call the REST
# endpoints through the authenticated tunes client.
module FeaturingNomination
  TYPE_ALIASES = {
    "app launch" => "APP_LAUNCH",
    "app_launch" => "APP_LAUNCH",
    "app enhancements" => "APP_ENHANCEMENTS",
    "app_enhancements" => "APP_ENHANCEMENTS",
    "new content" => "NEW_CONTENT",
    "new_content" => "NEW_CONTENT"
  }.freeze

  DEVICE_ALIASES = {
    "iphone" => "IPHONE",
    "ios (iphone)" => "IPHONE",
    "ios" => "IPHONE",
    "ipad" => "IPAD",
    "mac" => "MAC",
    "apple_tv" => "APPLE_TV",
    "apple tv" => "APPLE_TV",
    "apple_watch" => "APPLE_WATCH",
    "watchos" => "APPLE_WATCH",
    "watch" => "APPLE_WATCH"
  }.freeze

  NOMINATIONS_DIR = File.expand_path("../nominations", __dir__)

  module_function

  def load_file(path)
    absolute = File.expand_path(path)
    FastlaneCore::UI.user_error!("Nomination YAML not found: #{absolute}") unless File.file?(absolute)

    data = YAML.safe_load(File.read(absolute), permitted_classes: [Date, Time], aliases: true)
    FastlaneCore::UI.user_error!("Nomination YAML is empty: #{absolute}") unless data.is_a?(Hash)
    data
  end

  def resolve_path(name_or_path)
    return File.expand_path(name_or_path) if name_or_path && File.file?(File.expand_path(name_or_path))

    candidates = []
    if name_or_path && !name_or_path.empty?
      candidates << File.join(NOMINATIONS_DIR, name_or_path)
      candidates << File.join(NOMINATIONS_DIR, "#{name_or_path}.yml")
      candidates << File.join(NOMINATIONS_DIR, "#{name_or_path}.yaml")
    end
    # With no name given, use the only YAML file in fastlane/nominations/.
    yamls = Dir.glob(File.join(NOMINATIONS_DIR, "*.{yml,yaml}"))
    candidates << yamls.first if yamls.one?

    found = candidates.find { |p| File.file?(p) }
    FastlaneCore::UI.user_error!(
      "No nomination YAML found. Tried:\n  #{candidates.uniq.join("\n  ")}\n" \
      "Pass file:path/to.yml or name:<file name> (required when fastlane/nominations/ has several)"
    ) unless found
    found
  end

  def normalize_type(raw)
    return nil if raw.nil?
    key = raw.to_s.strip
    return key if %w[APP_LAUNCH APP_ENHANCEMENTS NEW_CONTENT].include?(key)

    mapped = TYPE_ALIASES[key.downcase]
    FastlaneCore::UI.user_error!("Unknown nomination type #{raw.inspect}. Use APP_LAUNCH / APP_ENHANCEMENTS / NEW_CONTENT.") unless mapped
    mapped
  end

  def normalize_devices(list)
    Array(list).map do |raw|
      key = raw.to_s.strip
      next key if %w[IPHONE IPAD MAC APPLE_TV APPLE_VISION_PRO APPLE_WATCH].include?(key)

      mapped = DEVICE_ALIASES[key.downcase]
      FastlaneCore::UI.user_error!("Unknown device family #{raw.inspect}") unless mapped
      mapped
    end.uniq
  end

  def normalize_locales(list)
    Array(list).map { |l| l.to_s.strip.upcase }.reject(&:empty?).uniq
  end

  def iso8601_datetime(value, timezone_hint: nil)
    return nil if value.nil? || value.to_s.strip.empty?

    if value.is_a?(Time) || value.is_a?(DateTime)
      return value.to_time.utc.iso8601
    end

    text = value.to_s.strip
    return Time.parse(text).utc.iso8601 if text.include?("T")

    # Date-only: interpret in the publish-window timezone when provided.
    zone = timezone_hint.to_s.upcase
    offset = case zone
             when "EDT" then "-04:00"
             when "EST" then "-05:00"
             when "PDT" then "-07:00"
             when "PST" then "-08:00"
             when "UTC", "Z", "" then "+00:00"
             else
               # Fall back to local parse; Apple accepts any offset.
               nil
             end

    if offset
      Time.parse("#{text}T00:00:00#{offset}").utc.iso8601
    else
      Time.parse(text).utc.iso8601
    end
  end

  def attributes_payload(data, submitted:)
    window = data["publish_window"] || {}
    tz = window["timezone"]

    attrs = {
      name: data.fetch("name"),
      type: normalize_type(data.fetch("type")),
      description: data.fetch("description").to_s.strip,
      notes: (data["helpful_details"] || data["notes"]).to_s.strip,
      submitted: submitted,
      publishStartDate: iso8601_datetime(window["start"] || data["publish_start"], timezone_hint: tz),
      publishEndDate: iso8601_datetime(window["end"] || data["publish_end"], timezone_hint: tz),
      deviceFamilies: normalize_devices(data["device_families"] || data["platforms"]),
      locales: normalize_locales(data["locales"] || data["localizations"]),
      supplementalMaterialsUris: Array(data["supplemental_materials"] || data["supplemental_materials_uris"]),
      hasInAppEvents: !!data.fetch("new_in_app_event", data.fetch("has_in_app_events", false)),
      launchInSelectMarketsFirst: !!data.fetch("launch_certain_markets_first", data.fetch("launch_in_select_markets_first", false)),
      preOrderEnabled: !!data.fetch("includes_preorder", data.fetch("pre_order_enabled", false))
    }

    %i[publishStartDate publishEndDate].each do |key|
      FastlaneCore::UI.user_error!("Missing #{key} in nomination YAML") if attrs[key].nil? || attrs[key].empty?
    end
    FastlaneCore::UI.user_error!("deviceFamilies must not be empty") if attrs[:deviceFamilies].empty?
    FastlaneCore::UI.user_error!("locales must not be empty") if attrs[:locales].empty?

    attrs
  end

  def related_app_ids(data, default_app_id:)
    related = data["related_apps"]
    if related.nil? || (related.is_a?(Array) && related.empty?)
      [default_app_id]
    else
      Array(related).map(&:to_s)
    end
  end

  def create_body(data, app_id:, submitted:)
    {
      data: {
        type: "nominations",
        attributes: attributes_payload(data, submitted: submitted),
        relationships: {
          relatedApps: {
            data: related_app_ids(data, default_app_id: app_id).map { |id| { type: "apps", id: id } }
          }
        }
      }
    }
  end

  def update_body(nomination_id, data, submitted:)
    {
      data: {
        type: "nominations",
        id: nomination_id,
        attributes: attributes_payload(data, submitted: submitted)
      }
    }
  end

  def fetch(client, nomination_id)
    client.get("v1/nominations/#{nomination_id}").body.fetch("data")
  rescue Spaceship::UnexpectedResponse => e
    return nil if e.message.to_s.include?("404") || e.message.to_s.downcase.include?("not found")

    raise
  end

  def sync!(client:, app_identifier:, path:, dry_run: false, submit: false)
    data = load_file(path)
    nomination_id = data["nomination_id"]&.to_s
    nomination_id = nil if nomination_id.nil? || nomination_id.strip.empty?

    app = Spaceship::ConnectAPI::App.find(app_identifier)
    FastlaneCore::UI.user_error!("App Store Connect app not found for #{app_identifier}") unless app

    existing = nomination_id ? fetch(client, nomination_id) : nil
    state = existing&.dig("attributes", "state")

    if submit && state == "SUBMITTED"
      FastlaneCore::UI.important("Nomination is already SUBMITTED — sync will refresh fields and keep submitted: true.")
    elsif submit
      FastlaneCore::UI.important("submit:true — this will SUBMIT the nomination to Apple Editorial (not a draft save).")
    end

    # ASC update requires `submitted` or `archived`. Keep SUBMITTED nominations
    # submitted when refreshing copy; never escalate a DRAFT unless submit:true.
    if existing
      keep_submitted = (state == "SUBMITTED") || submit
      if state == "SUBMITTED" && !submit
        FastlaneCore::UI.message("Existing nomination is SUBMITTED — updating editable fields (type/related apps locked by ASC).")
      end
      body = update_body(existing["id"], data, submitted: keep_submitted)
      action = "PATCH v1/nominations/#{existing['id']}"
    else
      body = create_body(data, app_id: app.id, submitted: submit)
      action = "POST v1/nominations"
      FastlaneCore::UI.important("No nomination_id (or ID not found) — will create a new nomination.")
    end

    FastlaneCore::UI.message("Nomination file: #{path}")
    FastlaneCore::UI.message("Action: #{action}")
    FastlaneCore::UI.message("Payload submitted flag: #{body.dig(:data, :attributes, :submitted)}")

    if dry_run
      FastlaneCore::UI.success("Dry run — no ASC write. Payload:")
      require "json"
      puts JSON.pretty_generate(JSON.parse(body.to_json))
      return { dry_run: true, body: body, existing: existing }
    end

    response = if existing
                 client.patch("v1/nominations/#{existing['id']}", body)
               else
                 client.post("v1/nominations", body)
               end

    result = response.body.fetch("data")
    new_id = result["id"]
    new_state = result.dig("attributes", "state")

    if nomination_id.nil? || nomination_id != new_id
      FastlaneCore::UI.important("Write nomination_id: \"#{new_id}\" back into #{File.basename(path)} so re-runs update this draft.")
    end

    FastlaneCore::UI.success("✅ Featuring nomination synced: id=#{new_id} state=#{new_state}")
    unless new_state == "SUBMITTED"
      FastlaneCore::UI.message("Submit Nomination remains a deliberate human step in App Store Connect")
      FastlaneCore::UI.message("(or re-run with submit:true when editorial timing is right).")
    end

    { id: new_id, state: new_state, body: body }
  end
end

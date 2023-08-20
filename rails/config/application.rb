require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
# require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Solobania
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.api_only = true

    config.time_zone = "Madrid"

    config.generators do |g|
      g.orm :active_record
      g.test_framework  :rspec,
        fixtures: true,
        fixture_replacement: :factory_bot,
        controller_specs: true,
        request_specs: false,
        view_specs: false,
        routing_specs: false,
        helper_specs: false

      g.assets          false
      g.helper          false
      g.channel         assets: false
    end

    config.autoload_paths += [
    ]

    if (rails_host = ENV["RAILS_HOST"])
      config.hosts << rails_host
    end
  end
end

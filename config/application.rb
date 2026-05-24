require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module CommonGoods
  class Application < Rails::Application
    config.load_defaults 8.0

    config.application_name = "CommonGoods"

    # Active Job adapter
    config.active_job.queue_adapter = :solid_queue
    config.solid_queue.connects_to = { database: { writing: :queue } }

    # Time zone
    config.time_zone = "UTC"

    # Generators
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.stylesheets false
      g.helper false
    end
  end
end

source "https://rubygems.org"

ruby "~> 3.3"

gem "rails", "~> 8.0"
gem "pg", "~> 1.5"
gem "activerecord-postgis-adapter", ">= 11.0"
gem "puma", ">= 6.0"
gem "propshaft"

# Frontend
gem "turbo-rails", "~> 2.0"
gem "stimulus-rails", "~> 1.3"
gem "tailwindcss-rails", "~> 3.0"
gem "jbuilder", "~> 2.12"
gem "kaminari"

# Authentication
gem "bcrypt", "~> 3.1"

# Geolocation
gem "geocoder", "~> 1.8"
gem "rgeo", "~> 3.0"
gem "rgeo-activerecord", "~> 8.0"

# Image processing
gem "image_processing", "~> 1.13"
gem "active_storage_validations", "~> 1.0"

# Background jobs
gem "solid_queue", "~> 1.0"
gem "mission_control-jobs", "~> 0.6"

# Action Cable
gem "redis", ">= 5.0"

# Boot
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[ windows mingw mswin x64_mingw jruby ]

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "faker"
  gem "factory_bot_rails"
  gem "rspec-rails", "~> 7.0"
end

group :development do
  gem "web-console"
  gem "error_highlight", ">= 0.6.0", platforms: [:ruby]
  gem "foreman"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
end

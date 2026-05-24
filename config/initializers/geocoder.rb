Geocoder.configure(
  lookup: :nominatim,
  ip_lookup: :ipinfo_io,
  language: :en,
  use_https: true,
  units: :km,
  distances: :spherical,
  timeout: 5,
  cache: Rails.cache,
  cache_options: {
    expiration: 1.day
  }
)

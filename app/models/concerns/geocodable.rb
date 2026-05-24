# app/models/concerns/geocodable.rb
# Shared geocoding logic for models with a location column.
module Geocodable
  extend ActiveSupport::Concern

  included do
    geocoded_by :address do |obj, results|
      if (geo = results.first)
        obj.location = RGeo::Geographic.spherical_factory(srid: 4326)
                                       .point(geo.longitude, geo.latitude)
      end
    end

    after_validation :geocode, if: ->(obj) { obj.respond_to?(:address) && obj.address.present? && obj.respond_to?(:address_changed?) && obj.address_changed? }

    scope :nearby, ->(point, radius_km = 5) {
      where(
        "ST_DWithin(location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)",
        point.x, point.y, radius_km * 1000
      )
    }

    scope :within_radius, ->(lat, lng, radius_km = 5) {
      where(
        "ST_DWithin(location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)",
        lng, lat, radius_km * 1000
      )
    }
  end

  def latitude
    location&.y
  end

  def longitude
    location&.x
  end

  def coordinates?
    location.present?
  end
end

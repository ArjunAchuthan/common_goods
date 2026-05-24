# app/jobs/geocoding_job.rb
# Asynchronously geocodes a user's address after registration/update.
class GeocodingJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user&.address.present?

    user.geocode
    user.save! if user.location_changed?
  rescue Geocoder::Error => e
    Rails.logger.warn("[GeocodingJob] Failed to geocode user #{user_id}: #{e.message}")
    # Retry with exponential backoff
    retry_job wait: 5.minutes if executions < 3
  end
end

# app/models/concerns/notifiable.rb
# Creates a notification and enqueues a broadcast job after model creation.
module Notifiable
  extend ActiveSupport::Concern

  private

  def create_notification(recipient:, actor:, action:)
    notification = Notification.create!(
      user: recipient,
      actor: actor,
      notifiable: self,
      action: action
    )

    NotificationBroadcastJob.perform_later(notification.id)
    notification
  end
end

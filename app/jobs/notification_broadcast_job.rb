# app/jobs/notification_broadcast_job.rb
# Processes and broadcasts a notification to the target user
# via ActionCable (Turbo Stream). Enqueued by the Notifiable concern.
class NotificationBroadcastJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)
    return unless notification

    # Broadcast a Turbo Stream to prepend the notification
    NotificationsChannel.broadcast_to(
      notification.user,
      {
        type: "notification",
        id: notification.id,
        message: notification.message,
        action: notification.action,
        actor_name: notification.actor.name,
        actor_initial: notification.actor.name.first.upcase,
        created_at: notification.created_at.iso8601,
        unread_count: notification.user.unread_notifications_count
      }.to_json
    )
  end
end

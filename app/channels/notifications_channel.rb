# app/channels/notifications_channel.rb
# Real-time notification delivery via ActionCable.
# When a notification is created, the NotificationBroadcastJob
# broadcasts a Turbo Stream to this channel for the target user.
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    # Cleanup when channel is unsubscribed
  end
end

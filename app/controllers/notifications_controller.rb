# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.recent.includes(:actor, :notifiable)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def mark_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace(@notification),
          (current_user.unread_notifications_count > 0 ?
            turbo_stream.update("notifications_badge", html: current_user.unread_notifications_count.to_s) :
            turbo_stream.remove("notifications_badge"))
        ]
      }
      format.html { redirect_to notifications_path }
    end
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("notifications_badge")
        ]
      }
      format.html { redirect_to notifications_path, notice: "All notifications marked as read." }
    end
  end
end

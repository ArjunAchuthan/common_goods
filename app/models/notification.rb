# app/models/notification.rb
class Notification < ApplicationRecord
  # --- Associations ---
  belongs_to :user
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  # --- Scopes ---
  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(20) }

  # --- Instance Methods ---
  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def message
    case action
    when "loan_requested"
      "#{actor.name} wants to borrow your #{notifiable_item_name}"
    when "loan_approved"
      "#{actor.name} approved your request for #{notifiable_item_name}"
    when "loan_declined"
      "#{actor.name} declined your request for #{notifiable_item_name}"
    when "item_returned"
      "#{notifiable_item_name} has been marked as returned"
    when "new_member"
      "#{actor.name} joined the neighborhood"
    else
      "You have a new notification"
    end
  end

  private

  def notifiable_item_name
    case notifiable
    when Loan then notifiable.item.name
    when Item then notifiable.name
    else "an item"
    end
  end
end

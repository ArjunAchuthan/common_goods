# app/models/loan.rb
class Loan < ApplicationRecord
  include Notifiable

  # --- Enums ---
  enum :status, {
    pending: 0,
    approved: 1,
    active: 2,
    returned: 3,
    declined: 4
  }

  # --- Associations ---
  belongs_to :item
  belongs_to :borrower, class_name: "User"

  has_one :owner, through: :item, source: :user

  # --- Validations ---
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate  :end_date_after_start_date
  validate  :no_overlapping_loans, on: :create
  validate  :cannot_borrow_own_item, on: :create

  # --- Scopes ---
  scope :upcoming,  -> { where(status: %i[approved]).where("start_date >= ?", Date.current) }
  scope :active_now, -> { where(status: :active) }
  scope :history,   -> { where(status: %i[returned declined]) }

  # --- State Transitions ---
  def approve!
    return unless pending?

    update!(status: :approved)
    create_notification(
      recipient: borrower,
      actor: item.user,
      action: "loan_approved"
    )
  end

  def decline!
    return unless pending?

    update!(status: :declined)
    item.update!(available: true)
    create_notification(
      recipient: borrower,
      actor: item.user,
      action: "loan_declined"
    )
  end

  def activate!
    return unless approved?

    update!(status: :active)
    item.update!(available: false)
  end

  def return_item!
    return unless active?

    update!(status: :returned)
    item.update!(available: true)
    create_notification(
      recipient: borrower,
      actor: item.user,
      action: "item_returned"
    )
  end

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "must be after start date") if end_date <= start_date
  end

  def no_overlapping_loans
    return if start_date.blank? || end_date.blank?

    overlapping = item.loans.where.not(status: %i[declined returned])
                      .where("start_date < ? AND end_date > ?", end_date, start_date)

    errors.add(:base, "This item is already booked for the selected dates") if overlapping.exists?
  end

  def cannot_borrow_own_item
    errors.add(:base, "You cannot borrow your own item") if borrower_id == item&.user_id
  end
end

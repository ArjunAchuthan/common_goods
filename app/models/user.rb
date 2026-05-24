# app/models/user.rb
class User < ApplicationRecord
  include Geocodable

  has_secure_password

  # --- Enums ---
  enum :role, { member: 0, captain: 1, admin: 2 }

  # --- Associations ---
  belongs_to :neighborhood, optional: true
  has_many   :sessions, dependent: :destroy
  has_many   :items, dependent: :destroy
  has_many   :loans_as_borrower, class_name: "Loan", foreign_key: :borrower_id, dependent: :destroy
  has_many   :sent_invitations, class_name: "Invitation", foreign_key: :inviter_id, dependent: :destroy
  has_many   :notifications, dependent: :destroy

  # --- Validations ---
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name,  presence: true
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }

  # --- Callbacks ---
  before_save :downcase_email

  # --- Scopes ---
  scope :in_neighborhood, ->(neighborhood) { where(neighborhood: neighborhood) }
  scope :captains_and_admins, -> { where(role: %i[captain admin]) }

  # --- Instance Methods ---
  def captain_or_admin?
    captain? || admin?
  end

  def unread_notifications_count
    notifications.unread.count
  end

  def borrowed_items
    Item.joins(:loans).where(loans: { borrower_id: id, status: %i[approved active] })
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end

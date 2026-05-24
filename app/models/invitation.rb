# app/models/invitation.rb
class Invitation < ApplicationRecord
  # --- Enums ---
  enum :status, { pending: 0, accepted: 1, expired: 2 }

  # --- Associations ---
  belongs_to :inviter, class_name: "User"
  belongs_to :neighborhood

  # --- Validations ---
  validates :invitee_email, presence: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validate  :invitee_not_already_member, on: :create

  # --- Callbacks ---
  before_validation :generate_token, on: :create

  # --- Scopes ---
  scope :active, -> { pending.where("created_at > ?", 7.days.ago) }

  # --- Class Methods ---
  def self.find_by_valid_token(token)
    active.find_by(token: token)
  end

  # --- Instance Methods ---
  def accept!(user)
    return false unless pending?

    transaction do
      update!(status: :accepted)
      user.update!(neighborhood: neighborhood)
    end

    true
  end

  def expired?
    super || (pending? && created_at < 7.days.ago)
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end

  def invitee_not_already_member
    if User.exists?(email: invitee_email, neighborhood: neighborhood)
      errors.add(:invitee_email, "is already a member of this neighborhood")
    end
  end
end

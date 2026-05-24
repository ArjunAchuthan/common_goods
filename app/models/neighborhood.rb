# app/models/neighborhood.rb
class Neighborhood < ApplicationRecord
  include Geocodable

  # --- Associations ---
  has_many :users, dependent: :nullify
  has_many :invitations, dependent: :destroy
  has_many :items, through: :users

  # --- Validations ---
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :radius_km, numericality: { greater_than: 0, less_than_or_equal_to: 10 }

  # --- Callbacks ---
  before_validation :generate_slug, on: :create

  # --- Instance Methods ---
  def member_count
    users.count
  end

  def available_items
    items.where(available: true, flagged: false)
  end

  def captains
    users.where(role: :captain)
  end

  private

  def generate_slug
    self.slug = name&.parameterize
  end
end

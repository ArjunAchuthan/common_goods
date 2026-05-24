# app/models/item.rb
class Item < ApplicationRecord
  include Notifiable

  # --- Enums ---
  enum :category, {
    tools: 0,
    garden: 1,
    kitchen: 2,
    sports: 3,
    camping: 4,
    electronics: 5,
    books: 6,
    furniture: 7,
    other: 8
  }

  enum :condition, {
    like_new: 0,
    good: 1,
    fair: 2,
    worn: 3
  }

  # --- Associations ---
  belongs_to :user
  has_many   :loans, dependent: :destroy
  has_many   :borrowers, through: :loans, source: :borrower
  has_many_attached :images

  # --- Validations ---
  validates :name, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 1000 }
  validates :category, presence: true
  validates :condition, presence: true
  validates :images, content_type: %w[image/png image/jpeg image/webp],
                     size: { less_than: 5.megabytes },
                     limit: { max: 5 }

  # --- Scopes ---
  scope :available,    -> { where(available: true, flagged: false) }
  scope :flagged,      -> { where(flagged: true) }
  scope :by_category,  ->(cat) { where(category: cat) if cat.present? }
  scope :search_by_name, ->(query) {
    where("items.name ILIKE :q OR items.description ILIKE :q", q: "%#{sanitize_sql_like(query)}%") if query.present?
  }

  # Nearby items via user's location
  scope :nearby, ->(point, radius_km = 5) {
    joins(:user).where(
      "ST_DWithin(users.location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)",
      point.x, point.y, radius_km * 1000
    )
  }

  scope :within_radius_of, ->(lat, lng, radius_km = 5) {
    joins(:user).where(
      "ST_DWithin(users.location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)",
      lng, lat, radius_km * 1000
    )
  }

  # --- Instance Methods ---
  def owner
    user
  end

  def currently_loaned?
    loans.where(status: :active).exists?
  end

  def active_loan
    loans.find_by(status: :active)
  end

  def pending_requests
    loans.where(status: :pending)
  end

  def thumbnail
    images.first
  end

  def flag!
    update!(flagged: true, available: false)
  end

  def unflag!
    update!(flagged: false, available: true)
  end
end

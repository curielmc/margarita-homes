class Property < ApplicationRecord
  belongs_to :zone
  belongs_to :building, optional: true
  belongs_to :data_source, optional: true
  has_many :property_photos, dependent: :destroy
  has_many :price_histories, dependent: :destroy

  validates :title, presence: true
  validates :property_type, presence: true, inclusion: { in: %w[house apartment condo townhouse land commercial] }
  validates :status, presence: true, inclusion: { in: %w[active pending sold withdrawn] }
  validates :current_price_usd, numericality: { greater_than: 0 }, allow_nil: true

  scope :active, -> { where(status: "active") }
  scope :featured, -> { where(featured: true) }
  scope :by_zone, ->(zone_id) { where(zone_id: zone_id) }
  scope :by_type, ->(type) { where(property_type: type) }
  scope :by_bedrooms, ->(min) { where("bedrooms >= ?", min) }
  scope :by_price_range, ->(min, max) {
    rel = all
    rel = rel.where("current_price_usd >= ?", min) if min.present?
    rel = rel.where("current_price_usd <= ?", max) if max.present?
    rel
  }

  def primary_photo
    property_photos.find_by(is_primary: true) || property_photos.order(:position).first
  end
end

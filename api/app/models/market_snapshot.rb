class MarketSnapshot < ApplicationRecord
  belongs_to :zone

  validates :period_start, presence: true
  validates :period_end, presence: true
  validates :zone_id, uniqueness: { scope: [:property_type, :period_start] }

  scope :chronological, -> { order(:period_start) }
  scope :by_type, ->(type) { where(property_type: type) }
  scope :recent, -> { order(period_start: :desc) }
end

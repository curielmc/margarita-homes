class PriceHistory < ApplicationRecord
  belongs_to :property
  belongs_to :data_source, optional: true

  validates :price_usd, presence: true, numericality: { greater_than: 0 }
  validates :price_type, presence: true, inclusion: { in: %w[asking reduced sold appraised] }
  validates :recorded_at, presence: true

  scope :chronological, -> { order(:recorded_at) }
  scope :by_type, ->(type) { where(price_type: type) }
end

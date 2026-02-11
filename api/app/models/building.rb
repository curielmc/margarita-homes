class Building < ApplicationRecord
  belongs_to :zone
  has_many :properties, dependent: :nullify

  validates :name, presence: true
  validates :zone, presence: true

  scope :by_zone, ->(zone_id) { where(zone_id: zone_id) }

  def units_listed
    properties.where(status: "active").count
  end

  def avg_price
    properties.where(status: "active").average(:current_price_usd)&.round(2)
  end

  def avg_price_per_sqft
    valid = properties.where(status: "active").where.not(current_price_usd: nil).where("sqft > 0")
    return nil if valid.none?
    (valid.sum("current_price_usd / sqft") / valid.count).round(2)
  end

  def price_range
    active = properties.where(status: "active")
    { min: active.minimum(:current_price_usd), max: active.maximum(:current_price_usd) }
  end
end

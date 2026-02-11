class Zone < ApplicationRecord
  has_many :properties, dependent: :destroy
  has_many :buildings, dependent: :destroy
  has_many :market_snapshots, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  scope :with_property_counts, -> {
    left_joins(:properties)
      .select("zones.*, COUNT(properties.id) AS properties_count")
      .group("zones.id")
  }

  private

  def generate_slug
    self.slug = name.parameterize
  end
end

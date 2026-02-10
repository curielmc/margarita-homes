class PropertyPhoto < ApplicationRecord
  belongs_to :property

  validates :url, presence: true

  scope :ordered, -> { order(:position) }
end

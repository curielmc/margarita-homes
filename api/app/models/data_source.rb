class DataSource < ApplicationRecord
  has_many :properties, dependent: :nullify
  has_many :price_histories, dependent: :nullify

  validates :name, presence: true
  validates :source_type, presence: true, inclusion: { in: %w[manual scraper api] }
end

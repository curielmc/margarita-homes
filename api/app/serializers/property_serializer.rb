class PropertySerializer
  include JSONAPI::Serializer

  attributes :title, :address, :property_type, :status, :bedrooms, :bathrooms,
             :sqft, :lot_sqft, :year_built, :description, :latitude, :longitude,
             :source_url, :featured, :current_price_usd, :listed_at, :sold_at

  belongs_to :zone
  has_many :property_photos
  has_many :price_histories

  attribute :zone_name do |property|
    property.zone.name
  end

  attribute :zone_slug do |property|
    property.zone.slug
  end

  attribute :primary_photo_url do |property|
    property.primary_photo&.url
  end

  attribute :building_id do |property|
    property.building_id
  end

  attribute :building_name do |property|
    property.building&.name
  end
end

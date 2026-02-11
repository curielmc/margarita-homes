class BuildingSerializer
  include JSONAPI::Serializer

  attributes :name, :address, :year_built, :total_units, :floors,
             :amenities, :description, :latitude, :longitude

  attribute :zone_name do |building|
    building.zone.name
  end

  attribute :zone_slug do |building|
    building.zone.slug
  end

  attribute :zone_id do |building|
    building.zone_id
  end

  attribute :units_listed do |building|
    building.units_listed
  end

  attribute :avg_price do |building|
    building.avg_price
  end

  attribute :avg_price_per_sqft do |building|
    building.avg_price_per_sqft
  end

  attribute :price_range do |building|
    building.price_range
  end
end

class ZoneSerializer
  include JSONAPI::Serializer

  attributes :name, :slug, :description, :latitude, :longitude, :bounds_json

  attribute :properties_count do |zone|
    zone.properties.count
  end

  attribute :avg_price do |zone|
    zone.properties.where(status: "active").average(:current_price_usd)&.round(2)
  end
end

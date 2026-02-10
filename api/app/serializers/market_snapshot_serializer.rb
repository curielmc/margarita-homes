class MarketSnapshotSerializer
  include JSONAPI::Serializer

  attributes :property_type, :period_start, :period_end, :avg_price, :median_price,
             :min_price, :max_price, :price_per_sqft, :listing_count, :sold_count

  attribute :zone_name do |snapshot|
    snapshot.zone.name
  end

  attribute :zone_slug do |snapshot|
    snapshot.zone.slug
  end
end

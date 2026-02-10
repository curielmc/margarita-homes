class PriceHistorySerializer
  include JSONAPI::Serializer

  attributes :price_usd, :price_type, :recorded_at, :notes
end

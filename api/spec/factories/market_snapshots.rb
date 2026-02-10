FactoryBot.define do
  factory :market_snapshot do
    zone { nil }
    property_type { "MyString" }
    period_start { "2026-02-09" }
    period_end { "2026-02-09" }
    avg_price { "9.99" }
    median_price { "9.99" }
    min_price { "9.99" }
    max_price { "9.99" }
    price_per_sqft { "9.99" }
    listing_count { 1 }
    sold_count { 1 }
  end
end

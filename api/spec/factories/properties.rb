FactoryBot.define do
  factory :property do
    zone { nil }
    data_source { nil }
    title { "MyString" }
    address { "MyString" }
    property_type { "MyString" }
    status { "MyString" }
    bedrooms { 1 }
    bathrooms { "9.99" }
    sqft { "9.99" }
    lot_sqft { "9.99" }
    year_built { 1 }
    description { "MyText" }
    latitude { "9.99" }
    longitude { "9.99" }
    source_url { "MyString" }
    featured { false }
    current_price_usd { "9.99" }
    listed_at { "2026-02-09" }
    sold_at { "2026-02-09" }
  end
end

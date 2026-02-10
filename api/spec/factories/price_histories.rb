FactoryBot.define do
  factory :price_history do
    property { nil }
    price_usd { "9.99" }
    price_type { "MyString" }
    recorded_at { "2026-02-09 20:59:14" }
    data_source { nil }
    notes { "MyText" }
  end
end

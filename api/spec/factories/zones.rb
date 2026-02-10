FactoryBot.define do
  factory :zone do
    name { "MyString" }
    slug { "MyString" }
    description { "MyText" }
    latitude { "9.99" }
    longitude { "9.99" }
    bounds_json { "" }
  end
end

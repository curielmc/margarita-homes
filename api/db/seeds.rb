puts "Seeding Margarita Homes..."

# Admin user
admin = AdminUser.find_or_create_by!(email: "admin@margaritahomes.com") do |u|
  u.name = "Admin"
  u.password = "password123"
end
puts "  Admin user: #{admin.email}"

# Data source
source = DataSource.find_or_create_by!(name: "Manual Entry") do |ds|
  ds.source_type = "manual"
  ds.base_url = nil
end

# Zones - real Margarita locations
zones_data = [
  { name: "Porlamar", slug: "porlamar", description: "Commercial capital of Margarita Island. Major shopping district with malls and duty-free stores.", latitude: 11.0, longitude: -63.85 },
  { name: "Pampatar", slug: "pampatar", description: "Historic fishing village turned resort area. Known for its colonial fort and waterfront dining.", latitude: 11.025, longitude: -63.78 },
  { name: "Playa El Agua", slug: "playa-el-agua", description: "Famous beach destination on the northern coast. Popular tourist area with beachfront properties.", latitude: 11.13, longitude: -63.87 },
  { name: "Juan Griego", slug: "juan-griego", description: "Charming town known for stunning sunsets. Quiet residential area on the western coast.", latitude: 11.08, longitude: -63.97 },
  { name: "La Asuncion", slug: "la-asuncion", description: "Island capital and administrative center. Colonial architecture and mountain views.", latitude: 11.03, longitude: -63.87 },
  { name: "Costa Azul", slug: "costa-azul", description: "Modern residential area between Porlamar and Pampatar. Growing commercial zone.", latitude: 11.01, longitude: -63.82 },
  { name: "El Yaque", slug: "el-yaque", description: "World-renowned windsurfing and kitesurfing beach. Laid-back beach community.", latitude: 10.93, longitude: -63.95 },
  { name: "Playa Guacuco", slug: "playa-guacuco", description: "Beautiful white sand beach area. Quieter residential zone with ocean views.", latitude: 11.05, longitude: -63.76 },
  { name: "Pedro Gonzalez", slug: "pedro-gonzalez", description: "Small fishing village with growing tourism. Affordable properties near beaches.", latitude: 11.11, longitude: -63.92 },
  { name: "Playa El Tirano", slug: "playa-el-tirano", description: "Scenic beach area adjacent to Playa El Agua. Mix of hotels and residential properties.", latitude: 11.14, longitude: -63.85 },
]

zones = zones_data.map do |data|
  Zone.find_or_create_by!(slug: data[:slug]) do |z|
    z.name = data[:name]
    z.description = data[:description]
    z.latitude = data[:latitude]
    z.longitude = data[:longitude]
  end
end
puts "  Created #{zones.size} zones"

# Properties
property_types = %w[house apartment condo townhouse land]
statuses = %w[active active active active pending sold]

property_templates = [
  { title: "Oceanfront Villa", type: "house", min: 250_000, max: 850_000, beds: [3, 4, 5], baths: [2.5, 3, 3.5], sqft: [2200, 4500] },
  { title: "Beach Apartment", type: "apartment", min: 65_000, max: 180_000, beds: [1, 2, 3], baths: [1, 2], sqft: [600, 1400] },
  { title: "Modern Condo", type: "condo", min: 85_000, max: 220_000, beds: [1, 2, 3], baths: [1, 1.5, 2], sqft: [700, 1600] },
  { title: "Colonial Townhouse", type: "townhouse", min: 120_000, max: 350_000, beds: [2, 3, 4], baths: [1.5, 2, 2.5], sqft: [1200, 2800] },
  { title: "Development Land", type: "land", min: 35_000, max: 200_000, beds: [0], baths: [0], sqft: [3000, 20000] },
  { title: "Luxury Penthouse", type: "condo", min: 180_000, max: 450_000, beds: [2, 3], baths: [2, 3], sqft: [1400, 2800] },
  { title: "Family Home", type: "house", min: 150_000, max: 400_000, beds: [3, 4], baths: [2, 3], sqft: [1800, 3200] },
  { title: "Studio near Beach", type: "apartment", min: 38_000, max: 75_000, beds: [0, 1], baths: [1], sqft: [350, 600] },
]

photo_urls = [
  "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800",
  "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800",
  "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800",
  "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800",
  "https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800",
  "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800",
  "https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=800",
  "https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=800",
  "https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?w=800",
  "https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?w=800",
]

properties = []
zones.each_with_index do |zone, zone_idx|
  num_properties = rand(2..4)
  num_properties.times do |i|
    template = property_templates.sample
    bedrooms = template[:beds].sample
    bathrooms = template[:baths].sample
    sqft = rand(template[:sqft][0]..template[:sqft][1])
    price = rand(template[:min]..template[:max])
    status = statuses.sample
    featured = rand < 0.2

    adjectives = ["Beautiful", "Charming", "Stunning", "Spacious", "Cozy", "Elegant", "Modern", "Renovated"]
    title = "#{adjectives.sample} #{template[:title]} in #{zone.name}"

    prop = Property.create!(
      zone: zone,
      data_source: source,
      title: title,
      address: "#{rand(100..999)} #{['Av. Principal', 'Calle', 'Av. Bolivar', 'Calle Santiago Mariño', 'Av. 4 de Mayo'].sample}, #{zone.name}",
      property_type: template[:type],
      status: status,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      sqft: sqft,
      lot_sqft: template[:type] == "land" ? sqft : (sqft * rand(1.2..3.0)).round,
      year_built: template[:type] == "land" ? nil : rand(1985..2024),
      description: "#{title}. Located in the heart of #{zone.name}, #{zone.description.downcase.sub(/\.\z/, '')}. This property offers #{bedrooms > 0 ? "#{bedrooms} bedrooms, #{bathrooms} bathrooms" : "a prime location"} and #{sqft.to_i} sq ft of living space.",
      latitude: zone.latitude + rand(-0.01..0.01),
      longitude: zone.longitude + rand(-0.01..0.01),
      featured: featured,
      current_price_usd: price,
      listed_at: Date.today - rand(7..365),
      sold_at: status == "sold" ? Date.today - rand(1..30) : nil,
    )

    # Add photos
    num_photos = rand(2..4)
    num_photos.times do |pi|
      prop.property_photos.create!(
        url: photo_urls.sample,
        position: pi,
        caption: pi == 0 ? "Main view" : ["Living area", "Kitchen", "Bedroom", "Bathroom", "Pool", "Garden", "Terrace"].sample,
        is_primary: pi == 0,
      )
    end

    # Add price history
    months_listed = rand(1..12)
    current_date = prop.listed_at
    current_price = (price * rand(1.05..1.20)).round

    PriceHistory.create!(
      property: prop,
      price_usd: current_price,
      price_type: "asking",
      recorded_at: current_date,
      data_source: source,
      notes: "Initial listing price"
    )

    if months_listed > 2 && rand < 0.6
      reduction_date = current_date + rand(30..90)
      reduced_price = (current_price * rand(0.85..0.95)).round
      PriceHistory.create!(
        property: prop,
        price_usd: reduced_price,
        price_type: "reduced",
        recorded_at: reduction_date,
        data_source: source,
        notes: "Price reduction"
      )
      current_price = reduced_price
    end

    if status == "sold"
      PriceHistory.create!(
        property: prop,
        price_usd: (current_price * rand(0.92..1.02)).round,
        price_type: "sold",
        recorded_at: prop.sold_at,
        data_source: source,
        notes: "Final sale price"
      )
    end

    properties << prop
  end
end
puts "  Created #{properties.size} properties with photos and price histories"

# Market snapshots - monthly for last 12 months
12.downto(1) do |months_ago|
  period_start = Date.today.beginning_of_month - months_ago.months
  period_end = period_start.end_of_month

  zones.each do |zone|
    %w[house apartment condo].each do |ptype|
      base_price = case ptype
                   when "house" then rand(180_000..350_000)
                   when "apartment" then rand(60_000..150_000)
                   when "condo" then rand(80_000..200_000)
                   end

      trend = 1.0 + (12 - months_ago) * rand(0.005..0.015)
      avg = (base_price * trend).round
      listing_count = rand(3..15)
      sold_count = rand(0..[listing_count - 1, 1].max)

      MarketSnapshot.create!(
        zone: zone,
        property_type: ptype,
        period_start: period_start,
        period_end: period_end,
        avg_price: avg,
        median_price: (avg * rand(0.9..1.1)).round,
        min_price: (avg * rand(0.5..0.7)).round,
        max_price: (avg * rand(1.3..1.8)).round,
        price_per_sqft: (avg.to_f / rand(800..2000)).round(2),
        listing_count: listing_count,
        sold_count: sold_count,
      )
    end
  end
end
puts "  Created market snapshots for 12 months"

puts "Seeding complete!"
puts "  #{Zone.count} zones"
puts "  #{Property.count} properties"
puts "  #{PropertyPhoto.count} photos"
puts "  #{PriceHistory.count} price history entries"
puts "  #{MarketSnapshot.count} market snapshots"
puts "  #{AdminUser.count} admin users"

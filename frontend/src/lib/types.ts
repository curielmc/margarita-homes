export interface Zone {
  id: string
  type: string
  attributes: {
    name: string
    slug: string
    description: string
    latitude: number
    longitude: number
    bounds_json: any
    properties_count: number
    avg_price: number | null
  }
}

export interface Property {
  id: string
  type: string
  attributes: {
    title: string
    address: string
    property_type: string
    status: string
    bedrooms: number
    bathrooms: number
    sqft: number
    lot_sqft: number
    year_built: number | null
    description: string
    latitude: number
    longitude: number
    source_url: string | null
    featured: boolean
    current_price_usd: number
    listed_at: string
    sold_at: string | null
    zone_name: string
    zone_slug: string
    primary_photo_url: string | null
    building_id: number | null
    building_name: string | null
  }
  relationships?: {
    property_photos?: { data: { id: string; type: string }[] }
    price_histories?: { data: { id: string; type: string }[] }
  }
}

export interface PropertyPhoto {
  id: string
  type: string
  attributes: {
    url: string
    position: number
    caption: string
    is_primary: boolean
  }
}

export interface PriceHistory {
  id: string
  type: string
  attributes: {
    price_usd: number
    price_type: string
    recorded_at: string
    notes: string
  }
}

export interface MarketSnapshot {
  id: string
  type: string
  attributes: {
    property_type: string
    period_start: string
    period_end: string
    avg_price: number
    median_price: number
    min_price: number
    max_price: number
    price_per_sqft: number
    listing_count: number
    sold_count: number
    zone_name: string
    zone_slug: string
    avg_days_on_market: number | null
    absorption_rate: number | null
  }
}

export interface MarketByType {
  type: string
  count: number
  avg_price: number | null
  median_price: number | null
  avg_price_per_sqft: number | null
  count_with_sqft: number
}

export interface MarketByZone {
  id: number
  name: string
  slug: string
  count: number
  avg_price: number | null
  median_price: number | null
  avg_price_per_sqft: number | null
}

export interface MarketOverview {
  total_listings: number
  avg_price: number
  median_price: number
  total_sold_last_30: number
  zones_count: number
  price_range: { min: number; max: number }
  by_type: MarketByType[]
  by_zone: MarketByZone[]
  featured_count: number
  avg_price_per_sqft: number | null
  median_price_per_sqft: number | null
  avg_days_on_market: number | null
  inventory_months: number | null
  absorption_rate: number | null
  price_reduction_pct: number | null
  year_over_year: number | null
}

export interface Building {
  id: string
  type: string
  attributes: {
    name: string
    address: string
    zone_id: number
    zone_name: string
    zone_slug: string
    latitude: number | null
    longitude: number | null
    year_built: number | null
    total_units: number | null
    floors: number | null
    amenities: string | null
    description: string | null
    units_listed: number
    avg_price: number | null
    avg_price_per_sqft: number | null
    price_range: { min: number | null; max: number | null }
  }
}

export interface PaginationMeta {
  current_page: number
  total_pages: number
  total_count: number
  per_page: number
}

export interface AdminUser {
  id: number
  email: string
  name: string
}

class MarketSnapshotService
  def self.generate(period_start: Date.today.beginning_of_month, period_end: Date.today.end_of_month)
    Zone.find_each do |zone|
      %w[house apartment condo townhouse land commercial].each do |property_type|
        properties = Property.where(zone: zone, property_type: property_type)
          .where("listed_at <= ? AND (sold_at IS NULL OR sold_at >= ?)", period_end, period_start)

        next if properties.empty?

        prices = properties.pluck(:current_price_usd).compact.sort
        next if prices.empty?

        sqft_prices = properties.where("sqft > 0").pluck(:current_price_usd, :sqft).map { |p, s| p / s }

        snapshot = MarketSnapshot.find_or_initialize_by(
          zone: zone,
          property_type: property_type,
          period_start: period_start
        )

        listing_count = properties.where(status: %w[active pending]).count
        sold_count = properties.where(status: "sold").where("sold_at >= ? AND sold_at <= ?", period_start, period_end).count

        # Avg days on market for properties with listed_at
        listed_props = properties.where.not(listed_at: nil)
        avg_dom = if listed_props.any?
          days = listed_props.pluck(:listed_at).map { |d| (period_end - d).to_f }
          (days.sum / days.size).round(2)
        end

        # Absorption rate: sold / listings
        abs_rate = listing_count > 0 ? (sold_count.to_f / listing_count).round(4) : nil

        snapshot.update!(
          period_end: period_end,
          avg_price: (prices.sum / prices.size).round(2),
          median_price: median(prices),
          min_price: prices.min,
          max_price: prices.max,
          price_per_sqft: sqft_prices.any? ? (sqft_prices.sum / sqft_prices.size).round(2) : nil,
          listing_count: listing_count,
          sold_count: sold_count,
          avg_days_on_market: avg_dom,
          absorption_rate: abs_rate
        )
      end
    end
  end

  def self.median(array)
    return nil if array.empty?
    sorted = array.sort
    mid = sorted.size / 2
    sorted.size.odd? ? sorted[mid] : ((sorted[mid - 1] + sorted[mid]) / 2.0).round(2)
  end
end

module Api
  module V1
    class MarketController < BaseController
      def overview
        active_properties = Property.where(status: "active")

        stats = {
          total_listings: active_properties.count,
          avg_price: active_properties.average(:current_price_usd)&.round(2),
          median_price: median_price(active_properties),
          total_sold_last_30: Property.where(status: "sold").where("sold_at >= ?", 30.days.ago).count,
          zones_count: Zone.count,
          price_range: {
            min: active_properties.minimum(:current_price_usd),
            max: active_properties.maximum(:current_price_usd)
          },
          by_type: property_type_stats(active_properties),
          by_zone: zone_stats,
          featured_count: active_properties.where(featured: true).count,
          avg_price_per_sqft: avg_price_per_sqft(active_properties),
          median_price_per_sqft: median_price_per_sqft(active_properties),
          avg_days_on_market: avg_days_on_market(active_properties),
          inventory_months: inventory_months(active_properties),
          absorption_rate: absorption_rate(active_properties),
          price_reduction_pct: price_reduction_pct(active_properties),
          year_over_year: year_over_year_change
        }

        render json: { data: stats }
      end

      def trends
        zone_id = params[:zone_id]
        property_type = params[:property_type]
        months = (params[:months] || 12).to_i

        snapshots = MarketSnapshot.includes(:zone)
          .where("period_start >= ?", months.months.ago.beginning_of_month)
          .order(:period_start)

        snapshots = snapshots.where(zone_id: zone_id) if zone_id.present?
        snapshots = snapshots.by_type(property_type) if property_type.present?

        render json: MarketSnapshotSerializer.new(snapshots).serializable_hash
      end

      private

      def median_price(scope)
        prices = scope.pluck(:current_price_usd).compact.sort
        return nil if prices.empty?
        mid = prices.size / 2
        prices.size.odd? ? prices[mid] : ((prices[mid - 1] + prices[mid]) / 2.0).round(2)
      end

      def property_type_stats(scope)
        scope.group(:property_type).count.map do |type, count|
          type_scope = scope.where(property_type: type)
          prices = type_scope.pluck(:current_price_usd).compact.sort
          mid = prices.size / 2
          median = if prices.empty?
            nil
          elsif prices.size.odd?
            prices[mid]
          else
            ((prices[mid - 1] + prices[mid]) / 2.0).round(2)
          end

          sqft_scope = type_scope.where.not(current_price_usd: nil).where("sqft > 0")
          price_sqft = sqft_scope.any? ? (sqft_scope.sum("current_price_usd / sqft") / sqft_scope.count).round(2) : nil

          {
            type: type,
            count: count,
            avg_price: type_scope.average(:current_price_usd)&.round(2),
            median_price: median,
            avg_price_per_sqft: price_sqft,
            count_with_sqft: sqft_scope.count
          }
        end
      end

      def zone_stats
        Zone.with_property_counts.map do |zone|
          active = zone.properties.where(status: "active")
          prices = active.pluck(:current_price_usd).compact.sort
          mid = prices.size / 2
          median = if prices.empty?
            nil
          elsif prices.size.odd?
            prices[mid]
          else
            ((prices[mid - 1] + prices[mid]) / 2.0).round(2)
          end

          sqft_scope = active.where.not(current_price_usd: nil).where("sqft > 0")
          price_sqft = sqft_scope.any? ? (sqft_scope.sum("current_price_usd / sqft") / sqft_scope.count).round(2) : nil

          {
            id: zone.id,
            name: zone.name,
            slug: zone.slug,
            count: active.count,
            avg_price: active.average(:current_price_usd)&.round(2),
            median_price: median,
            avg_price_per_sqft: price_sqft
          }
        end
      end

      def avg_price_per_sqft(scope)
        valid = scope.where.not(current_price_usd: nil).where("sqft > 0")
        return nil if valid.none?
        (valid.sum("current_price_usd / sqft") / valid.count).round(2)
      end

      def median_price_per_sqft(scope)
        ratios = scope.where.not(current_price_usd: nil).where("sqft > 0")
                      .pluck(:current_price_usd, :sqft)
                      .map { |p, s| (p / s).round(2) }
                      .sort
        return nil if ratios.empty?
        mid = ratios.size / 2
        ratios.size.odd? ? ratios[mid] : ((ratios[mid - 1] + ratios[mid]) / 2.0).round(2)
      end

      def avg_days_on_market(scope)
        listed = scope.where.not(listed_at: nil)
        return nil if listed.none?
        listed.average(Arel.sql("CURRENT_DATE - listed_at"))&.round(1)
      end

      def inventory_months(scope)
        active_count = scope.count
        sold_last_12mo = Property.where(status: "sold").where("sold_at >= ?", 12.months.ago).count
        return nil if sold_last_12mo == 0
        (active_count / (sold_last_12mo / 12.0)).round(1)
      end

      def absorption_rate(scope)
        active_count = scope.count
        return nil if active_count == 0
        sold_last_30 = Property.where(status: "sold").where("sold_at >= ?", 30.days.ago).count
        (sold_last_30.to_f / active_count).round(4)
      end

      def price_reduction_pct(scope)
        total = scope.count
        return nil if total == 0
        reduced = scope.joins(:price_histories)
                       .where("price_histories.notes ILIKE ?", "%reduced%")
                       .distinct.count
        ((reduced.to_f / total) * 100).round(1)
      end

      def year_over_year_change
        latest = MarketSnapshot.order(period_start: :desc).first
        return nil unless latest

        year_ago = MarketSnapshot.where(period_start: latest.period_start - 12.months)
        return nil if year_ago.none?

        latest_avg = MarketSnapshot.where(period_start: latest.period_start).average(:avg_price)
        old_avg = year_ago.average(:avg_price)
        return nil unless latest_avg && old_avg && old_avg > 0

        (((latest_avg - old_avg) / old_avg) * 100).round(1)
      end
    end
  end
end

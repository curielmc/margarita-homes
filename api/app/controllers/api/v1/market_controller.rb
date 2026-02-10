module Api
  module V1
    class MarketController < BaseController
      def overview
        active_properties = Property.where(status: "active")
        all_properties = Property.all

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
          featured_count: active_properties.where(featured: true).count
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
          { type: type, count: count, avg_price: scope.where(property_type: type).average(:current_price_usd)&.round(2) }
        end
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module Jasper
    class MarketController < BaseController
      # GET /api/jasper/market/summary
      def summary
        render_success({
          overview: market_overview,
          by_zone: zone_breakdown,
          by_type: type_breakdown,
          recent_activity: recent_activity
        })
      end

      # POST /api/jasper/market/snapshot
      def create_snapshot
        zone = Zone.find(params[:zone_id])

        snapshot = MarketSnapshot.new(
          zone: zone,
          property_type: params[:property_type],
          period_start: params[:period_start] || Date.current.beginning_of_month,
          period_end: params[:period_end] || Date.current
        )

        # Calculate stats from properties
        properties = zone.properties
        properties = properties.by_type(params[:property_type]) if params[:property_type].present?

        snapshot.listing_count = properties.active.count
        snapshot.sold_count = properties.where(status: "sold")
                                       .where("sold_at >= ?", snapshot.period_start)
                                       .count

        prices = properties.active.where.not(current_price_usd: nil).pluck(:current_price_usd)
        if prices.any?
          snapshot.avg_price = prices.sum / prices.size
          snapshot.min_price = prices.min
          snapshot.max_price = prices.max
          snapshot.median_price = calculate_median(prices)

          sqft_prices = properties.active
                                 .where.not(current_price_usd: nil)
                                 .where("sqft > 0")
                                 .pluck(:current_price_usd, :sqft)
          if sqft_prices.any?
            snapshot.price_per_sqft = sqft_prices.sum { |p, s| p / s } / sqft_prices.size
          end
        end

        # Calculate new stats
        listed = properties.active.where.not(listed_at: nil)
        if listed.any?
          days = listed.pluck(:listed_at).map { |d| (snapshot.period_end - d).to_f }
          snapshot.avg_days_on_market = (days.sum / days.size).round(2)
        end

        snapshot.absorption_rate = snapshot.listing_count > 0 ? (snapshot.sold_count.to_f / snapshot.listing_count).round(4) : nil

        if snapshot.save
          render_success(snapshot_json(snapshot), status: :created)
        else
          render_error("Failed to create snapshot", errors: snapshot.errors.full_messages)
        end
      end

      # GET /api/jasper/market/trends
      def trends
        zone_id = params[:zone_id]
        months = (params[:months] || 6).to_i

        snapshots = MarketSnapshot
                     .where("period_start >= ?", months.months.ago.beginning_of_month)
                     .order(:period_start)

        snapshots = snapshots.where(zone_id: zone_id) if zone_id.present?

        render_success({
          period: "#{months} months",
          snapshots: snapshots.map { |s| snapshot_json(s) }
        })
      end

      private

      def market_overview
        active = Property.active
        {
          total_listings: active.count,
          avg_price: active.average(:current_price_usd)&.round(2),
          median_price: calculate_median(active.where.not(current_price_usd: nil).pluck(:current_price_usd)),
          price_range: {
            min: active.minimum(:current_price_usd),
            max: active.maximum(:current_price_usd)
          },
          avg_sqft: active.where("sqft > 0").average(:sqft)&.round(0),
          avg_price_per_sqft: calculate_avg_price_per_sqft(active),
          avg_days_on_market: calculate_avg_dom(active),
          absorption_rate: calculate_absorption_rate(active),
          inventory_months: calculate_inventory_months(active)
        }
      end

      def zone_breakdown
        Zone.with_property_counts.map do |zone|
          active = zone.properties.active
          {
            id: zone.id,
            name: zone.name,
            slug: zone.slug,
            listings: zone.properties_count,
            active_listings: active.count,
            avg_price: active.average(:current_price_usd)&.round(2),
            avg_price_per_sqft: calculate_avg_price_per_sqft(active)
          }
        end
      end

      def type_breakdown
        Property::PROPERTY_TYPES ||= %w[house apartment condo townhouse land commercial]

        Property::PROPERTY_TYPES.map do |type|
          active = Property.active.by_type(type)
          {
            type: type,
            count: active.count,
            avg_price: active.average(:current_price_usd)&.round(2),
            avg_sqft: active.where("sqft > 0").average(:sqft)&.round(0),
            avg_price_per_sqft: calculate_avg_price_per_sqft(active)
          }
        end
      rescue
        Property.group(:property_type).count.map do |type, count|
          active = Property.active.by_type(type)
          {
            type: type,
            count: count,
            avg_price: active.average(:current_price_usd)&.round(2),
            avg_price_per_sqft: calculate_avg_price_per_sqft(active)
          }
        end
      end

      def recent_activity
        {
          new_listings_7d: Property.where("listed_at >= ?", 7.days.ago).count,
          new_listings_30d: Property.where("listed_at >= ?", 30.days.ago).count,
          sold_7d: Property.where("sold_at >= ?", 7.days.ago).count,
          sold_30d: Property.where("sold_at >= ?", 30.days.ago).count,
          price_changes_7d: PriceHistory.where("recorded_at >= ?", 7.days.ago).count
        }
      end

      def snapshot_json(snapshot)
        {
          id: snapshot.id,
          zone: { id: snapshot.zone.id, name: snapshot.zone.name },
          property_type: snapshot.property_type,
          period_start: snapshot.period_start,
          period_end: snapshot.period_end,
          listing_count: snapshot.listing_count,
          sold_count: snapshot.sold_count,
          avg_price: snapshot.avg_price,
          median_price: snapshot.median_price,
          min_price: snapshot.min_price,
          max_price: snapshot.max_price,
          price_per_sqft: snapshot.price_per_sqft,
          avg_days_on_market: snapshot.avg_days_on_market,
          absorption_rate: snapshot.absorption_rate
        }
      end

      def calculate_median(prices)
        return nil if prices.blank?
        sorted = prices.sort
        mid = sorted.size / 2
        sorted.size.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
      end

      def calculate_avg_price_per_sqft(properties)
        valid = properties.where.not(current_price_usd: nil).where("sqft > 0")
        return nil if valid.none?

        total = valid.sum("current_price_usd / sqft")
        (total / valid.count).round(2)
      end

      def calculate_avg_dom(scope)
        listed = scope.where.not(listed_at: nil)
        return nil if listed.none?
        listed.average(Arel.sql("CURRENT_DATE - listed_at"))&.round(1)
      end

      def calculate_absorption_rate(scope)
        active_count = scope.count
        return nil if active_count == 0
        sold_last_30 = Property.where(status: "sold").where("sold_at >= ?", 30.days.ago).count
        (sold_last_30.to_f / active_count).round(4)
      end

      def calculate_inventory_months(scope)
        active_count = scope.count
        sold_last_12mo = Property.where(status: "sold").where("sold_at >= ?", 12.months.ago).count
        return nil if sold_last_12mo == 0
        (active_count / (sold_last_12mo / 12.0)).round(1)
      end
    end
  end
end

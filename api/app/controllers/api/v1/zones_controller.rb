module Api
  module V1
    class ZonesController < BaseController
      def index
        zones = Zone.with_property_counts.order(:name)

        render json: ZoneSerializer.new(zones).serializable_hash
      end

      def show
        zone = Zone.find_by!(slug: params[:id])

        render json: ZoneSerializer.new(zone).serializable_hash
      end
    end
  end
end

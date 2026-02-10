module Api
  module V1
    module Admin
      class ZonesController < BaseController
        before_action :set_zone, only: [:update, :destroy]

        def create
          zone = Zone.new(zone_params)

          if zone.save
            render json: ZoneSerializer.new(zone).serializable_hash, status: :created
          else
            render json: { errors: zone.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          if @zone.update(zone_params)
            render json: ZoneSerializer.new(@zone).serializable_hash
          else
            render json: { errors: @zone.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          @zone.destroy!
          head :no_content
        end

        private

        def set_zone
          @zone = Zone.find(params[:id])
        end

        def zone_params
          params.permit(:name, :slug, :description, :latitude, :longitude, :bounds_json)
        end
      end
    end
  end
end

module Api
  module V1
    class BuildingsController < BaseController
      def index
        buildings = Building.includes(:zone)
        buildings = buildings.by_zone(params[:zone_id]) if params[:zone_id].present?
        buildings = buildings.order(:name)

        paginated = paginate(buildings)

        render json: {
          data: BuildingSerializer.new(paginated).serializable_hash[:data],
          meta: pagination_meta(paginated)
        }
      end

      def show
        building = Building.includes(:zone, properties: [:property_photos, :zone]).find(params[:id])

        properties = building.properties.order(created_at: :desc)
        property_data = PropertySerializer.new(properties).serializable_hash[:data]

        result = BuildingSerializer.new(building).serializable_hash
        result[:included_properties] = property_data
        render json: result
      end
    end
  end
end

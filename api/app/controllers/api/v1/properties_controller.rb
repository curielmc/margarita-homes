module Api
  module V1
    class PropertiesController < BaseController
      def index
        properties = Property.includes(:zone, :property_photos)

        properties = properties.by_zone(params[:zone_id]) if params[:zone_id].present?
        properties = properties.by_type(params[:property_type]) if params[:property_type].present?
        properties = properties.by_bedrooms(params[:bedrooms_min]) if params[:bedrooms_min].present?
        properties = properties.by_price_range(params[:price_min], params[:price_max])
        properties = properties.where(status: params[:status]) if params[:status].present?
        properties = properties.featured if params[:featured] == "true"

        properties = properties.order(created_at: :desc)
        paginated = paginate(properties)

        render json: {
          data: PropertySerializer.new(paginated).serializable_hash[:data],
          meta: pagination_meta(paginated)
        }
      end

      def show
        property = Property.includes(:zone, :property_photos, :price_histories).find(params[:id])

        render json: PropertySerializer.new(property, include: [:property_photos, :price_histories]).serializable_hash
      end
    end
  end
end

module Api
  module V1
    module Admin
      class PropertiesController < BaseController
        before_action :set_property, only: [:show, :update, :destroy]

        def index
          properties = Property.includes(:zone).order(created_at: :desc)
          properties = properties.where("title ILIKE ?", "%#{params[:search]}%") if params[:search].present?

          paginated = paginate(properties)

          render json: {
            data: PropertySerializer.new(paginated).serializable_hash[:data],
            meta: pagination_meta(paginated)
          }
        end

        def show
          render json: PropertySerializer.new(@property, include: [:property_photos, :price_histories]).serializable_hash
        end

        def create
          property = Property.new(property_params)

          if property.save
            render json: PropertySerializer.new(property).serializable_hash, status: :created
          else
            render json: { errors: property.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          if @property.update(property_params)
            render json: PropertySerializer.new(@property).serializable_hash
          else
            render json: { errors: @property.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          @property.destroy!
          head :no_content
        end

        private

        def set_property
          @property = Property.find(params[:id])
        end

        def property_params
          params.permit(
            :zone_id, :data_source_id, :title, :address, :property_type, :status,
            :bedrooms, :bathrooms, :sqft, :lot_sqft, :year_built, :description,
            :latitude, :longitude, :source_url, :featured, :current_price_usd,
            :listed_at, :sold_at
          )
        end
      end
    end
  end
end

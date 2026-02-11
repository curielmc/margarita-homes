module Api
  module V1
    module Admin
      class BuildingsController < BaseController
        before_action :set_building, only: [:show, :update, :destroy]

        def index
          buildings = Building.includes(:zone).order(:name)
          buildings = buildings.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?

          paginated = paginate(buildings)

          render json: {
            data: BuildingSerializer.new(paginated).serializable_hash[:data],
            meta: pagination_meta(paginated)
          }
        end

        def show
          render json: BuildingSerializer.new(@building).serializable_hash
        end

        def create
          building = Building.new(building_params)

          if building.save
            render json: BuildingSerializer.new(building).serializable_hash, status: :created
          else
            render json: { errors: building.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          if @building.update(building_params)
            render json: BuildingSerializer.new(@building).serializable_hash
          else
            render json: { errors: @building.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          @building.destroy!
          head :no_content
        end

        private

        def set_building
          @building = Building.find(params[:id])
        end

        def building_params
          params.permit(
            :name, :address, :zone_id, :latitude, :longitude,
            :year_built, :total_units, :floors, :amenities, :description
          )
        end
      end
    end
  end
end

module Api
  module V1
    module Admin
      class PriceHistoriesController < BaseController
        before_action :set_property

        def create
          history = @property.price_histories.new(price_history_params)

          if history.save
            render json: PriceHistorySerializer.new(history).serializable_hash, status: :created
          else
            render json: { errors: history.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          history = @property.price_histories.find(params[:id])
          history.destroy!
          head :no_content
        end

        private

        def set_property
          @property = Property.find(params[:property_id])
        end

        def price_history_params
          params.permit(:price_usd, :price_type, :recorded_at, :data_source_id, :notes)
        end
      end
    end
  end
end

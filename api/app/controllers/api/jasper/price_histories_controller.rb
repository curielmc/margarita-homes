# frozen_string_literal: true

module Api
  module Jasper
    class PriceHistoriesController < BaseController
      before_action :set_property

      # GET /api/jasper/properties/:property_id/price_histories
      def index
        histories = @property.price_histories.order(recorded_at: :desc)
        
        render_success({
          property_id: @property.id,
          property_title: @property.title,
          current_price: @property.current_price_usd,
          price_histories: histories.map { |h| history_json(h) }
        })
      end

      # POST /api/jasper/properties/:property_id/price_histories
      def create
        history = @property.price_histories.new(history_params)
        history.recorded_at ||= Time.current

        if history.save
          # Optionally update property's current price
          if params[:update_current_price] == true || params[:update_current_price] == "true"
            @property.update!(current_price_usd: history.price_usd)
          end

          render_success(history_json(history), status: :created)
        else
          render_error("Failed to create price history", errors: history.errors.full_messages)
        end
      end

      # DELETE /api/jasper/properties/:property_id/price_histories/:id
      def destroy
        history = @property.price_histories.find(params[:id])
        history.destroy!
        render_success({ message: "Price history deleted", id: params[:id].to_i })
      end

      private

      def set_property
        @property = Property.find(params[:property_id])
      rescue ActiveRecord::RecordNotFound
        render_error("Property not found", status: :not_found)
      end

      def history_params
        params.require(:price_history).permit(:price_usd, :price_type, :recorded_at, :notes)
      end

      def history_json(history)
        {
          id: history.id,
          price_usd: history.price_usd,
          price_type: history.price_type,
          recorded_at: history.recorded_at,
          notes: history.notes,
          created_at: history.created_at
        }
      end
    end
  end
end

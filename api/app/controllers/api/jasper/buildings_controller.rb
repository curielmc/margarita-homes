# frozen_string_literal: true

module Api
  module Jasper
    class BuildingsController < BaseController
      before_action :set_building, only: [:show, :update, :destroy, :assign_properties, :properties]

      # GET /api/jasper/buildings
      def index
        buildings = Building.includes(:zone).order(:name)
        buildings = buildings.by_zone(params[:zone_id]) if params[:zone_id].present?

        render_success({
          buildings: buildings.map { |b| building_json(b) }
        })
      end

      # GET /api/jasper/buildings/:id
      def show
        render_success(building_json(@building, full: true))
      end

      # POST /api/jasper/buildings
      def create
        building = Building.new(building_params)

        if building.save
          render_success(building_json(building), status: :created)
        else
          render_error("Failed to create building", errors: building.errors.full_messages)
        end
      end

      # PUT /api/jasper/buildings/:id
      def update
        if @building.update(building_params)
          render_success(building_json(@building))
        else
          render_error("Failed to update building", errors: @building.errors.full_messages)
        end
      end

      # DELETE /api/jasper/buildings/:id
      def destroy
        @building.destroy!
        render_success({ message: "Building deleted", id: params[:id].to_i })
      end

      # POST /api/jasper/buildings/:id/assign_properties
      def assign_properties
        property_ids = params[:property_ids] || []
        properties = Property.where(id: property_ids)
        properties.update_all(building_id: @building.id)

        render_success({
          message: "#{properties.count} properties assigned to #{@building.name}",
          building: building_json(@building)
        })
      end

      # GET /api/jasper/buildings/:id/properties
      def properties
        props = @building.properties.includes(:property_photos, :zone).order(created_at: :desc)

        render_success({
          building: { id: @building.id, name: @building.name },
          properties: props.map { |p| property_summary(p) }
        })
      end

      private

      def set_building
        @building = Building.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error("Building not found", status: :not_found)
      end

      def building_params
        params.require(:building).permit(
          :name, :address, :zone_id, :latitude, :longitude,
          :year_built, :total_units, :floors, :amenities, :description
        )
      end

      def building_json(building, full: false)
        json = {
          id: building.id,
          name: building.name,
          address: building.address,
          zone: { id: building.zone.id, name: building.zone.name, slug: building.zone.slug },
          units_listed: building.units_listed,
          avg_price: building.avg_price,
          avg_price_per_sqft: building.avg_price_per_sqft,
          price_range: building.price_range
        }

        if full
          json.merge!(
            latitude: building.latitude,
            longitude: building.longitude,
            year_built: building.year_built,
            total_units: building.total_units,
            floors: building.floors,
            amenities: building.amenities,
            description: building.description,
            created_at: building.created_at,
            updated_at: building.updated_at
          )
        end

        json
      end

      def property_summary(property)
        {
          id: property.id,
          title: property.title,
          address: property.address,
          current_price_usd: property.current_price_usd,
          bedrooms: property.bedrooms,
          bathrooms: property.bathrooms,
          sqft: property.sqft,
          status: property.status,
          primary_photo: property.primary_photo&.url
        }
      end
    end
  end
end

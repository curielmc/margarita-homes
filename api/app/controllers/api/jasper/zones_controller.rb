# frozen_string_literal: true

module Api
  module Jasper
    class ZonesController < BaseController
      before_action :set_zone, only: [:show, :update, :destroy]

      # GET /api/jasper/zones
      def index
        zones = Zone.with_property_counts.order(:name)
        
        render_success({
          zones: zones.map { |z| zone_json(z) }
        })
      end

      # GET /api/jasper/zones/:id
      def show
        render_success(zone_json(@zone, full: true))
      end

      # POST /api/jasper/zones
      def create
        zone = Zone.new(zone_params)

        if zone.save
          render_success(zone_json(zone), status: :created)
        else
          render_error("Failed to create zone", errors: zone.errors.full_messages)
        end
      end

      # PUT /api/jasper/zones/:id
      def update
        if @zone.update(zone_params)
          render_success(zone_json(@zone))
        else
          render_error("Failed to update zone", errors: @zone.errors.full_messages)
        end
      end

      # DELETE /api/jasper/zones/:id
      def destroy
        if @zone.properties.exists?
          render_error("Cannot delete zone with existing properties", status: :conflict)
        else
          @zone.destroy!
          render_success({ message: "Zone deleted", id: params[:id].to_i })
        end
      end

      # GET /api/jasper/zones/:id/properties
      def properties
        @zone = Zone.find(params[:id])
        properties = @zone.properties.includes(:property_photos).order(created_at: :desc)

        render_success({
          zone: { id: @zone.id, name: @zone.name },
          properties: properties.map { |p| property_summary(p) }
        })
      end

      private

      def set_zone
        @zone = Zone.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error("Zone not found", status: :not_found)
      end

      def zone_params
        params.require(:zone).permit(:name, :slug, :description, :latitude, :longitude, :bounds_json)
      end

      def zone_json(zone, full: false)
        json = {
          id: zone.id,
          name: zone.name,
          slug: zone.slug,
          properties_count: zone.try(:properties_count) || zone.properties.count,
          latitude: zone.latitude,
          longitude: zone.longitude
        }

        if full
          json.merge!(
            description: zone.description,
            bounds_json: zone.bounds_json,
            price_stats: {
              avg: zone.properties.active.average(:current_price_usd)&.round(2),
              min: zone.properties.active.minimum(:current_price_usd),
              max: zone.properties.active.maximum(:current_price_usd)
            },
            created_at: zone.created_at,
            updated_at: zone.updated_at
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

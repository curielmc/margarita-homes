# frozen_string_literal: true

module Api
  module Jasper
    class PropertiesController < BaseController
      before_action :set_property, only: [:show, :update, :destroy, :add_photos, :delete_photo, :update_photo, :cleanup_photos]

      # GET /api/jasper/properties
      def index
        properties = Property.includes(:zone, :building, :property_photos, :price_histories)

        # Filters
        properties = properties.by_zone(params[:zone_id]) if params[:zone_id].present?
        properties = properties.by_type(params[:property_type]) if params[:property_type].present?
        properties = properties.where(status: params[:status]) if params[:status].present?
        properties = properties.by_bedrooms(params[:min_bedrooms]) if params[:min_bedrooms].present?
        properties = properties.by_price_range(params[:min_price], params[:max_price])
        properties = properties.featured if params[:featured] == "true"

        # Search
        if params[:q].present?
          q = "%#{params[:q]}%"
          properties = properties.where("title ILIKE ? OR address ILIKE ? OR description ILIKE ?", q, q, q)
        end

        # Sorting
        sort_by = params[:sort_by] || "created_at"
        sort_dir = params[:sort_dir] == "asc" ? :asc : :desc
        properties = properties.order(sort_by => sort_dir)

        # Pagination
        page = (params[:page] || 1).to_i
        per_page = [(params[:per_page] || 25).to_i, 100].min
        total = properties.count
        properties = properties.offset((page - 1) * per_page).limit(per_page)

        render_success({
          properties: properties.map { |p| property_json(p) },
          pagination: {
            page: page,
            per_page: per_page,
            total: total,
            total_pages: (total.to_f / per_page).ceil
          }
        })
      end

      # GET /api/jasper/properties/:id
      def show
        render_success(property_json(@property, full: true))
      end

      # POST /api/jasper/properties
      def create
        property = Property.new(property_params)

        if property.save
          # Handle photos if provided
          create_photos(property, params[:photos]) if params[:photos].present?

          # Record initial price history
          if property.current_price_usd.present?
            property.price_histories.create!(
              price_usd: property.current_price_usd,
              price_type: "asking",
              recorded_at: Time.current,
              notes: "Initial listing price"
            )
          end

          render_success(property_json(property, full: true), status: :created)
        else
          render_error("Failed to create property", errors: property.errors.full_messages)
        end
      end

      # PUT /api/jasper/properties/:id
      def update
        old_price = @property.current_price_usd

        if @property.update(property_params)
          # Track price changes
          if params[:property][:current_price_usd].present? && 
             @property.current_price_usd != old_price
            @property.price_histories.create!(
              price_usd: @property.current_price_usd,
              price_type: "asking",
              recorded_at: Time.current,
              notes: "Price updated from $#{old_price&.to_i} to $#{@property.current_price_usd.to_i}"
            )
          end

          render_success(property_json(@property, full: true))
        else
          render_error("Failed to update property", errors: @property.errors.full_messages)
        end
      end

      # DELETE /api/jasper/properties/:id
      def destroy
        @property.destroy!
        render_success({ message: "Property deleted", id: params[:id].to_i })
      end

      # POST /api/jasper/properties/bulk
      def bulk_create
        results = { created: [], failed: [] }

        params[:properties].each do |prop_params|
          property = Property.new(prop_params.permit(*permitted_property_attrs))
          
          if property.save
            # Record initial price
            if property.current_price_usd.present?
              property.price_histories.create!(
                price_usd: property.current_price_usd,
                price_type: "asking",
                recorded_at: Time.current,
                notes: "Initial listing price (bulk import)"
              )
            end
            results[:created] << { id: property.id, title: property.title }
          else
            results[:failed] << { 
              title: prop_params[:title], 
              errors: property.errors.full_messages 
            }
          end
        end

        render_success(results, status: results[:failed].empty? ? :created : :multi_status)
      end

      # POST /api/jasper/properties/:id/photos
      def add_photos
        photos_created = create_photos(@property, params[:photos])
        render_success({ 
          message: "#{photos_created.size} photo(s) added",
          photos: photos_created.map { |p| photo_json(p) }
        })
      end

      # DELETE /api/jasper/properties/:id/photos/:photo_id
      def delete_photo
        photo = @property.property_photos.find(params[:photo_id])
        photo.destroy!
        render_success({ message: "Photo deleted", id: params[:photo_id].to_i })
      rescue ActiveRecord::RecordNotFound
        render_error("Photo not found", status: :not_found)
      end

      # PATCH /api/jasper/properties/:id/photos/:photo_id
      def update_photo
        photo = @property.property_photos.find(params[:photo_id])
        
        # If setting as primary, unset all others first
        if params[:is_primary] == true || params[:is_primary] == "true"
          @property.property_photos.update_all(is_primary: false)
        end
        
        photo.update!(
          is_primary: params[:is_primary],
          caption: params[:caption],
          position: params[:position]
        )
        render_success(photo_json(photo))
      rescue ActiveRecord::RecordNotFound
        render_error("Photo not found", status: :not_found)
      end

      # DELETE /api/jasper/properties/:id/photos/cleanup
      # Removes all non-Cloudinary photos and sets the first Cloudinary photo as primary
      def cleanup_photos
        cloudinary_photos = @property.property_photos.where("url LIKE ?", "%res.cloudinary.com%")
        non_cloudinary = @property.property_photos.where.not("url LIKE ?", "%res.cloudinary.com%")
        
        deleted_count = non_cloudinary.count
        non_cloudinary.destroy_all
        
        # Set first Cloudinary photo as primary
        if cloudinary_photos.any?
          @property.property_photos.update_all(is_primary: false)
          cloudinary_photos.first.update!(is_primary: true)
        end
        
        render_success({
          message: "Cleanup complete",
          deleted: deleted_count,
          remaining: cloudinary_photos.count
        })
      end

      # POST /api/jasper/properties/:id/mark_sold
      def mark_sold
        @property = Property.find(params[:id])
        
        if @property.update(status: "sold", sold_at: params[:sold_at] || Date.current)
          # Record sold price if provided
          if params[:sold_price].present?
            @property.price_histories.create!(
              price_usd: params[:sold_price],
              price_type: "sold",
              recorded_at: Time.current,
              notes: "Property sold"
            )
          end
          
          render_success(property_json(@property, full: true))
        else
          render_error("Failed to mark property as sold", errors: @property.errors.full_messages)
        end
      end

      # GET /api/jasper/properties/stats
      def stats
        stats = {
          total: Property.count,
          by_status: Property.group(:status).count,
          by_type: Property.group(:property_type).count,
          by_zone: Property.joins(:zone).group("zones.name").count,
          price_stats: {
            avg: Property.active.average(:current_price_usd)&.round(2),
            min: Property.active.minimum(:current_price_usd),
            max: Property.active.maximum(:current_price_usd),
            median: calculate_median_price
          },
          recent: {
            listed_last_7_days: Property.where("listed_at >= ?", 7.days.ago).count,
            sold_last_30_days: Property.where("sold_at >= ?", 30.days.ago).count
          }
        }

        render_success(stats)
      end

      private

      def set_property
        @property = Property.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error("Property not found", status: :not_found)
      end

      def property_params
        params.require(:property).permit(*permitted_property_attrs)
      end

      def permitted_property_attrs
        [
          :title, :address, :description, :current_price_usd,
          :bedrooms, :bathrooms, :sqft, :lot_sqft,
          :property_type, :status, :zone_id, :building_id,
          :latitude, :longitude, :year_built,
          :featured, :listed_at, :sold_at, :source_url
        ]
      end

      def create_photos(property, photos_params)
        photos_params.map do |photo|
          cloudinary_url = nil
          original_url = photo[:url]

          # Handle base64 data
          if photo[:base64].present?
            cloudinary_url = upload_base64_to_cloudinary(photo[:base64])
            original_url = "base64_upload"
          elsif original_url.present?
            cloudinary_url = CloudinaryService.upload_from_url(original_url)
          end

          property.property_photos.create!(
            url: cloudinary_url || original_url,
            original_url: original_url,
            caption: photo[:caption],
            is_primary: photo[:is_primary] || false,
            position: photo[:position] || property.property_photos.count
          )
        end
      end

      def upload_base64_to_cloudinary(base64_data)
        # Handle data URL format (data:image/jpeg;base64,...)
        if base64_data.start_with?("data:")
          base64_data = base64_data.split(",")[1]
        end

        # Decode and create temp file
        decoded = Base64.decode64(base64_data)
        temp_file = Tempfile.new(["photo", ".jpg"])
        temp_file.binmode
        temp_file.write(decoded)
        temp_file.rewind

        CloudinaryService.upload_file(temp_file)
      rescue => e
        Rails.logger.error("[PropertiesController] Base64 upload failed: #{e.message}")
        nil
      ensure
        temp_file&.close
        temp_file&.unlink
      end

      def property_json(property, full: false)
        json = {
          id: property.id,
          title: property.title,
          address: property.address,
          current_price_usd: property.current_price_usd,
          bedrooms: property.bedrooms,
          bathrooms: property.bathrooms,
          sqft: property.sqft,
          property_type: property.property_type,
          status: property.status,
          featured: property.featured,
          zone: {
            id: property.zone.id,
            name: property.zone.name,
            slug: property.zone.slug
          },
          primary_photo: property.primary_photo&.url,
          listed_at: property.listed_at,
          building: property.building ? { id: property.building.id, name: property.building.name } : nil,
          created_at: property.created_at,
          updated_at: property.updated_at
        }

        if full
          json.merge!(
            description: property.description,
            lot_sqft: property.lot_sqft,
            latitude: property.latitude,
            longitude: property.longitude,
            year_built: property.year_built,
            sold_at: property.sold_at,
            source_url: property.source_url,
            photos: property.property_photos.order(:position).map { |p| photo_json(p) },
            price_history: property.price_histories.order(recorded_at: :desc).map { |h|
              {
                id: h.id,
                price_usd: h.price_usd,
                price_type: h.price_type,
                recorded_at: h.recorded_at,
                notes: h.notes
              }
            }
          )
        end

        json
      end

      def photo_json(photo)
        {
          id: photo.id,
          url: photo.url,
          caption: photo.caption,
          is_primary: photo.is_primary,
          position: photo.position
        }
      end

      def calculate_median_price
        prices = Property.active.where.not(current_price_usd: nil).pluck(:current_price_usd).sort
        return nil if prices.empty?

        mid = prices.size / 2
        prices.size.odd? ? prices[mid] : (prices[mid - 1] + prices[mid]) / 2.0
      end
    end
  end
end

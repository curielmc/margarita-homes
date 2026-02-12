# frozen_string_literal: true

module Api
  module Jasper
    class TasksController < BaseController
      # POST /api/jasper/tasks/migrate_photos
      def migrate_photos
        photos = PropertyPhoto.where.not("url LIKE ?", "%res.cloudinary.com%")
        total = photos.count

        if total.zero?
          render json: { success: true, message: "No photos need migration", migrated: 0, failed: 0 }
          return
        end

        migrated = 0
        failed = 0
        errors = []

        photos.find_each do |photo|
          source_url = photo.original_url.presence || photo.url
          cloudinary_url = CloudinaryService.upload_from_url(source_url)

          if cloudinary_url
            photo.update!(url: cloudinary_url, original_url: source_url)
            migrated += 1
          else
            failed += 1
            photo.update!(original_url: source_url) if photo.original_url.blank?
            errors << { photo_id: photo.id, property_id: photo.property_id, url: source_url }
          end

          sleep 0.3 # Rate limiting
        end

        render json: {
          success: true,
          message: "Migration complete",
          total: total,
          migrated: migrated,
          failed: failed,
          errors: errors.first(10) # Only show first 10 errors
        }
      end

      # GET /api/jasper/tasks/photo_status
      def photo_status
        total_photos = PropertyPhoto.count
        cloudinary_photos = PropertyPhoto.where("url LIKE ?", "%res.cloudinary.com%").count
        instagram_photos = PropertyPhoto.where("url LIKE ?", "%cdninstagram.com%").count
        other_photos = total_photos - cloudinary_photos - instagram_photos

        render json: {
          success: true,
          total_photos: total_photos,
          cloudinary_photos: cloudinary_photos,
          instagram_photos: instagram_photos,
          other_photos: other_photos,
          needs_migration: instagram_photos + other_photos
        }
      end
    end
  end
end

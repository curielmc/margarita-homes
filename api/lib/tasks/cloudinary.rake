# frozen_string_literal: true

namespace :cloudinary do
  desc "Migrate existing property photos to Cloudinary"
  task migrate_photos: :environment do
    photos = PropertyPhoto.where("url NOT LIKE ?", "%res.cloudinary.com%")
    total = photos.count
    puts "Found #{total} photos to migrate"

    migrated = 0
    failed = 0

    photos.find_each do |photo|
      source_url = photo.original_url.presence || photo.url
      cloudinary_url = CloudinaryService.upload_from_url(source_url)

      if cloudinary_url
        photo.update!(url: cloudinary_url, original_url: source_url)
        migrated += 1
        puts "  [#{migrated + failed}/#{total}] Migrated photo ##{photo.id}"
      else
        failed += 1
        # Preserve original_url even on failure so retry can find it
        photo.update!(original_url: source_url) if photo.original_url.blank?
        puts "  [#{migrated + failed}/#{total}] FAILED photo ##{photo.id}: #{source_url}"
      end

      sleep 0.5 # Rate limiting
    end

    puts "\nDone! Migrated: #{migrated}, Failed: #{failed}"
  end

  desc "Retry uploading photos that failed previous migration"
  task retry_failed: :environment do
    photos = PropertyPhoto.where("url NOT LIKE ?", "%res.cloudinary.com%")
                          .where.not(original_url: nil)
    total = photos.count
    puts "Found #{total} photos to retry"

    migrated = 0
    failed = 0

    photos.find_each do |photo|
      cloudinary_url = CloudinaryService.upload_from_url(photo.original_url)

      if cloudinary_url
        photo.update!(url: cloudinary_url)
        migrated += 1
        puts "  [#{migrated + failed}/#{total}] Migrated photo ##{photo.id}"
      else
        failed += 1
        puts "  [#{migrated + failed}/#{total}] FAILED photo ##{photo.id}: #{photo.original_url}"
      end

      sleep 0.5
    end

    puts "\nDone! Migrated: #{migrated}, Failed: #{failed}"
  end
end

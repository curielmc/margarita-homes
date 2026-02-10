# frozen_string_literal: true

class CloudinaryService
  FOLDER = "margarita-homes"
  CLOUD_NAME = "dpw8dmauk"

  def self.upload_from_url(source_url)
    return nil if source_url.blank?
    return source_url if cloudinary_url?(source_url)

    result = Cloudinary::Uploader.upload(source_url, folder: FOLDER, resource_type: "image")
    result["secure_url"]
  rescue CloudinaryException, StandardError => e
    Rails.logger.error("[CloudinaryService] Upload failed for #{source_url}: #{e.message}")
    nil
  end

  def self.upload_file(file)
    return nil if file.blank?

    result = Cloudinary::Uploader.upload(file, folder: FOLDER, resource_type: "image")
    result["secure_url"]
  rescue CloudinaryException, StandardError => e
    Rails.logger.error("[CloudinaryService] File upload failed: #{e.message}")
    nil
  end

  def self.cloudinary_url?(url)
    url.to_s.include?("res.cloudinary.com/#{CLOUD_NAME}/")
  end
end

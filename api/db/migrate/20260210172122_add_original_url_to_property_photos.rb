class AddOriginalUrlToPropertyPhotos < ActiveRecord::Migration[8.1]
  def change
    add_column :property_photos, :original_url, :string
  end
end

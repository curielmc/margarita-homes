class CreatePropertyPhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :property_photos do |t|
      t.references :property, null: false, foreign_key: true
      t.string :url, null: false
      t.integer :position, default: 0
      t.string :caption
      t.boolean :is_primary, default: false

      t.timestamps
    end
  end
end

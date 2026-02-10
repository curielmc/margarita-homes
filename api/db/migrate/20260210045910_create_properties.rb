class CreateProperties < ActiveRecord::Migration[8.1]
  def change
    create_table :properties do |t|
      t.references :zone, null: false, foreign_key: true
      t.references :data_source, foreign_key: true
      t.string :title, null: false
      t.string :address
      t.string :property_type, null: false, default: "house"
      t.string :status, null: false, default: "active"
      t.integer :bedrooms
      t.decimal :bathrooms, precision: 3, scale: 1
      t.decimal :sqft, precision: 10, scale: 2
      t.decimal :lot_sqft, precision: 10, scale: 2
      t.integer :year_built
      t.text :description
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.string :source_url
      t.boolean :featured, default: false
      t.decimal :current_price_usd, precision: 12, scale: 2
      t.date :listed_at
      t.date :sold_at

      t.timestamps
    end

    add_index :properties, :property_type
    add_index :properties, :status
    add_index :properties, :featured
    add_index :properties, :current_price_usd
  end
end

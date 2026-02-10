class CreateZones < ActiveRecord::Migration[8.1]
  def change
    create_table :zones do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.jsonb :bounds_json

      t.timestamps
    end

    add_index :zones, :slug, unique: true
  end
end

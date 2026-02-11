class CreateBuildings < ActiveRecord::Migration[8.1]
  def change
    create_table :buildings do |t|
      t.string :name, null: false
      t.string :address
      t.references :zone, null: false, foreign_key: true
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.integer :year_built
      t.integer :total_units
      t.integer :floors
      t.text :amenities
      t.text :description

      t.timestamps
    end

    add_index :buildings, :name
  end
end

class CreateMarketSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :market_snapshots do |t|
      t.references :zone, null: false, foreign_key: true
      t.string :property_type
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.decimal :avg_price, precision: 12, scale: 2
      t.decimal :median_price, precision: 12, scale: 2
      t.decimal :min_price, precision: 12, scale: 2
      t.decimal :max_price, precision: 12, scale: 2
      t.decimal :price_per_sqft, precision: 10, scale: 2
      t.integer :listing_count, default: 0
      t.integer :sold_count, default: 0

      t.timestamps
    end

    add_index :market_snapshots, [:zone_id, :property_type, :period_start], unique: true, name: "idx_snapshots_zone_type_period"
  end
end

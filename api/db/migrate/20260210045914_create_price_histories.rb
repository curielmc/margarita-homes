class CreatePriceHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :price_histories do |t|
      t.references :property, null: false, foreign_key: true
      t.decimal :price_usd, precision: 12, scale: 2, null: false
      t.string :price_type, null: false, default: "asking"
      t.datetime :recorded_at, null: false
      t.references :data_source, foreign_key: true
      t.text :notes

      t.timestamps
    end

    add_index :price_histories, :price_type
    add_index :price_histories, :recorded_at
  end
end

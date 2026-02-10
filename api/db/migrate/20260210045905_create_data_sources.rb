class CreateDataSources < ActiveRecord::Migration[8.1]
  def change
    create_table :data_sources do |t|
      t.string :name
      t.string :source_type
      t.string :base_url
      t.datetime :last_scraped_at

      t.timestamps
    end
  end
end

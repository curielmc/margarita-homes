class AddStatsToMarketSnapshots < ActiveRecord::Migration[8.1]
  def change
    add_column :market_snapshots, :avg_days_on_market, :decimal, precision: 8, scale: 2
    add_column :market_snapshots, :absorption_rate, :decimal, precision: 8, scale: 4
  end
end

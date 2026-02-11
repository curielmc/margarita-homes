class AddBuildingToProperties < ActiveRecord::Migration[8.1]
  def change
    add_reference :properties, :building, foreign_key: true, null: true
  end
end

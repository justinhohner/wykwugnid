class ChangeRecipeIdColumnInLocations < ActiveRecord::Migration[5.0]
  def change
    remove_column :locations, :recipe_id, :integer
    add_column :locations, :restaurant_id, :integer
  end
end

class CreateMenuItemIngredients < ActiveRecord::Migration[5.0]
  def change
    create_table :menu_item_ingredients do |t|
      t.integer :food_id
      t.integer :menu_item_id

      t.timestamps
    end
  end
end

class CreateRestaurantJoinMenus < ActiveRecord::Migration[5.0]
  def change
    create_table :restaurant_join_menus do |t|
      t.integer :restaurant_id
      t.integer :menu_id

      t.timestamps
    end
  end
end

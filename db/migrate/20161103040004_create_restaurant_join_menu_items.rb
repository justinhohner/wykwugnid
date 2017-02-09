class CreateRestaurantJoinMenuItems < ActiveRecord::Migration[5.0]
  def change
    create_table :restaurant_join_menu_items do |t|
      t.integer :restaurant_id
      t.integer :menu_item_id

      t.timestamps
    end
  end
end

class DropTableMenuJoinMenuItemsAgain < ActiveRecord::Migration[5.0]
  def change
    drop_table :table_menu_item_join_menu_items
  end
end

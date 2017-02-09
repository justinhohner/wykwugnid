class DropTableMenuJoinMenuItems < ActiveRecord::Migration[5.0]
  def change
    drop_table :menu_join_menu_items
  end
end

class CreateTableMenuItemJoinMenuItems < ActiveRecord::Migration[5.0]
  def change
    create_table :menu_item_join_menu_items do |t|
      t.integer :menu_id
      t.integer :menu_item_id
    end
  end
end

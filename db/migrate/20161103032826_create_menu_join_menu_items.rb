class CreateMenuJoinMenuItems < ActiveRecord::Migration[5.0]
  def change
    create_table :menu_join_menu_items do |t|
      t.references :source, foreign_key: true
      t.references :food, foreign_key: true

      t.timestamps
    end
  end
end

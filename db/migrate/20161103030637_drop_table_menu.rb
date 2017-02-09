class DropTableMenu < ActiveRecord::Migration[5.0]
  def change
    drop_table :menus
  end
end

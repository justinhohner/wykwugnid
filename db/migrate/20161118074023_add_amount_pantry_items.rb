class AddAmountPantryItems < ActiveRecord::Migration[5.0]
  def change
    add_column :pantry_items, :amount, :decimal
  end
end

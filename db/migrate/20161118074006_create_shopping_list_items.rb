class CreateShoppingListItems < ActiveRecord::Migration[5.0]
  def change
    create_table :shopping_list_items do |t|
      t.references :food, foreign_key: true
      t.references :shopping_list, foreign_key: true
      t.decimal :amount

      t.timestamps
    end
  end
end

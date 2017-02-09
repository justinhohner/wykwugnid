class CreateMealItems < ActiveRecord::Migration[5.0]
  def change
    create_table :meal_items do |t|
      t.integer :meal_id
      t.integer :food_id
      t.decimal :amount, default: 0.0

      t.timestamps
    end
    add_index :meal_items, :meal_id
    add_index :meal_items, :food_id
  end
end

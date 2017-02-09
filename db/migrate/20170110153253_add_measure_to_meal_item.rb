class AddMeasureToMealItem < ActiveRecord::Migration[5.0]
  def change
    add_column :meal_items, :measure, :string, default: 'unit'
  end
end

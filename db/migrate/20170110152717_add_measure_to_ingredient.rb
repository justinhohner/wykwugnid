class AddMeasureToIngredient < ActiveRecord::Migration[5.0]
  def change
    add_column :ingredients, :measure, :string, default: 'unit'
  end
end

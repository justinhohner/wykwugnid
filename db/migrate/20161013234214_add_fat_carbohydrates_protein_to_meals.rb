class AddFatCarbohydratesProteinToMeals < ActiveRecord::Migration[5.0]
  def change
    add_column :meals, :fat, :decimal
    add_column :meals, :carbohydrates, :decimal
    add_column :meals, :protein, :decimal
  end
end

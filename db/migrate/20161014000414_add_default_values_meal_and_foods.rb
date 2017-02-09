class AddDefaultValuesMealAndFoods < ActiveRecord::Migration[5.0]
  def change
    change_column :meals, :fat, :decimal, default: 0.0
    change_column :meals, :carbohydrates, :decimal, default: 0.0
    change_column :meals, :protein, :decimal, default: 0.0
    change_column :foods, :calories, :decimal, default: 0.0
    change_column :foods, :fat, :decimal, default: 0.0
    change_column :foods, :carbohydrates, :decimal, default: 0.0
    change_column :foods, :protein, :decimal, default: 0.0
  end
end

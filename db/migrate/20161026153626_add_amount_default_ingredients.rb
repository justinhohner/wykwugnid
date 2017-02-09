class AddAmountDefaultIngredients < ActiveRecord::Migration[5.0]
  def change
    change_column :ingredients, :amount, :decimal, default: 0.0
  end
end

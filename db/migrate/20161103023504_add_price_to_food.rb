class AddPriceToFood < ActiveRecord::Migration[5.0]
  def change
    add_column :foods, :price, :decimal
  end
end

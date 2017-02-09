class AddDefaultToFoodsTitle < ActiveRecord::Migration[5.0]
  def change
    change_column :foods, :title, :string, default: ""
  end
end

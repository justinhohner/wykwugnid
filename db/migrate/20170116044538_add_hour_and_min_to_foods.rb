class AddHourAndMinToFoods < ActiveRecord::Migration[5.0]
  def change
    add_column :foods, :hr, :integer
    add_column :foods, :min, :integer
  end
end

class AddEerToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :eer, :integer
  end
end

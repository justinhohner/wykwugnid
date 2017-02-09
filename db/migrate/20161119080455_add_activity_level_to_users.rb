class AddActivityLevelToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :activity_level, :string
  end
end

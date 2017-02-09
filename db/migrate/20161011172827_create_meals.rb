class CreateMeals < ActiveRecord::Migration[5.0]
  def change
    create_table :meals do |t|
      t.string :title, default: ""
      t.boolean :published, default: false
      t.integer :user_id
      t.integer :calories, default: 0

      t.timestamps
    end
    add_index :meals, :user_id
  end
end

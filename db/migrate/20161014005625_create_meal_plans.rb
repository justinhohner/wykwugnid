class CreateMealPlans < ActiveRecord::Migration[5.0]
  def change
    create_table :meal_plans do |t|
      t.string :title, default: ""
      t.integer :user_id
      t.datetime :published_at
      t.decimal :calories, default: 0.0
      t.decimal :fat, default: 0.0
      t.decimal :carbohydrates, default: 0.0
      t.decimal :protein, default: 0.0

      t.timestamps
    end
    add_index :meal_plans, :user_id
  end
end

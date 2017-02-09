class CreateFoods < ActiveRecord::Migration[5.0]
  def change
    create_table :foods do |t|
      t.string :title
      t.decimal :calories
      t.decimal :fat
      t.decimal :carbohydrates
      t.decimal :protein
      t.integer :user_id
      t.string :type

      t.timestamps
    end
  end
end

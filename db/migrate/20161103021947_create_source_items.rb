class CreateSourceItems < ActiveRecord::Migration[5.0]
  def change
    create_table :source_items do |t|
      t.references :source, foreign_key: true
      t.references :food, foreign_key: true

      t.timestamps
    end
  end
end

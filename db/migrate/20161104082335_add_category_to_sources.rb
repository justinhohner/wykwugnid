class AddCategoryToSources < ActiveRecord::Migration[5.0]
  def change
    add_column :sources, :category, :string
  end
end

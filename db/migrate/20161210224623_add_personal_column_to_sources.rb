class AddPersonalColumnToSources < ActiveRecord::Migration[5.0]
  def change
    add_column :sources, :personal, :boolean, default: false
  end
end

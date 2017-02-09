class AddSourceIdToSources < ActiveRecord::Migration[5.0]
  def change
    add_column :sources, :source_id, :integer
  end
end

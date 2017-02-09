class AddUsedAtToConstraintSets < ActiveRecord::Migration[5.0]
  def change
    add_column :constraint_sets, :used_at, :date
  end
end

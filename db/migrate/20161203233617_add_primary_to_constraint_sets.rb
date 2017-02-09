class AddPrimaryToConstraintSets < ActiveRecord::Migration[5.0]
  def change
    add_column :constraint_sets, :primary, :boolean, default: false
  end
end

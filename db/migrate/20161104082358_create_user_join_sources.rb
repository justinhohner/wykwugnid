class CreateUserJoinSources < ActiveRecord::Migration[5.0]
  def change
    create_table :user_join_sources do |t|
      t.references :user, foreign_key: true
      t.references :source, foreign_key: true

      t.timestamps
    end
  end
end

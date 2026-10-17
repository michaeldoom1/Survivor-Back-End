class CreateUserGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :user_groups do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false

      t.timestamps
    end

    create_table :user_group_memberships do |t|
      t.references :user_group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :user_group_memberships, [ :user_group_id, :user_id ], unique: true
  end
end

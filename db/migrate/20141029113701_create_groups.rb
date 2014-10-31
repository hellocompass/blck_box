class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name

      t.timestamps
    end

    create_table :groups_users do |t|
      t.integer :user_id
      t.integer :group_id

      t.timestamps
    end

    add_index :groups_users, :user_id
    add_index :groups_users, :group_id
    add_index :groups_users, [:user_id, :group_id], unique: true
  end
end

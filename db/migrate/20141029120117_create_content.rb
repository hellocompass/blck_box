class CreateContent < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.integer :group_id

      t.timestamps
    end

    create_table :contents_users do |t|
      t.integer :content_id
      t.integer :user_id

      t.timestamps
    end

    add_index :contents, :group_id
    add_index :contents_users, :content_id
    add_index :contents_users, :user_id
  end
end

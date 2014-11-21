class AddMetadataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :street_address, :string
    add_column :users, :locality, :string
    add_column :users, :region, :string
    add_column :users, :country, :string
    add_column :users, :zip_code, :string
    add_column :users, :birthday, :time

    remove_column :users, :phone_number, :string

    create_table :phone_numbers do |t|
      t.integer :phone_number, limit: 5
      t.string :number_type
      t.boolean :preferred
      t.references :user, index: true
    end
    add_index :phone_numbers, :phone_number, unique: true
    add_index :phone_numbers, [:user_id, :preferred], unique: true, where: 'preferred = true'

    create_table :emails do |t|
      t.string :email
      t.string :email_type
      t.boolean :preferred
      t.references :user, index: true
    end
    add_index :emails, :email, unique: true
    add_index :emails, [:user_id, :preferred], unique: true, where: 'preferred = true'
  end
end

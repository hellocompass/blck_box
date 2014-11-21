class AddPendingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pending, :boolean, default: false, allow_null: false
  end
end

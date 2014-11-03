class AddEnabledToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :enabled, :boolean, default: true, allow_null: false
  end
end

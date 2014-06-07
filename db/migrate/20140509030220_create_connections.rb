class CreateConnections < ActiveRecord::Migration
  def up
    create_table :connections do |t|
      t.integer :user_id
      t.string :source
      t.string :source_id
      t.string :auth_token

      t.timestamps
    end

    ActiveRecord::Base.connection.execute(
      %Q{
        CREATE UNIQUE INDEX user_source_constraint ON connections (user_id, source)
        WHERE source = source AND user_id = user_id;
      }
    )
  end

  def down
    drop_table :connections
  end
end

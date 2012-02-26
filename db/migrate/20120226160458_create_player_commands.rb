class CreatePlayerCommands < ActiveRecord::Migration
  def change
    create_table :player_commands do |t|
      t.string :action
      t.string :parameter

      t.timestamps
    end
  end
end

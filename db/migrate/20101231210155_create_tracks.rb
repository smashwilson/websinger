class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.string :title
      t.string :artist
      t.string :album
      t.integer :track_number
      t.integer :disc_number
      t.integer :length
      t.string :path

      t.timestamps
    end
  end

  def self.down
    drop_table :tracks
  end
end

class AddSlugsToTrack < ActiveRecord::Migration
  def self.up
    change_table 'tracks' do |t|
      t.string :album_slug
      t.string :artist_slug
      t.index :album_slug
      t.index :artist_slug
    end
  end

  def self.down
    change_table 'tracks' do |t|
      t.remove :album_slug
      t.remove :artist_slug
      t.remove_index :album_slug
      t.remove_index :artist_slug
    end
  end
end

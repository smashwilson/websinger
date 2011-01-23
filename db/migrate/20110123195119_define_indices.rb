class DefineIndices < ActiveRecord::Migration
  def self.up
    change_table 'tracks' do |t|
      t.index :title
      t.index :artist
      t.index :album
    end
  end

  def self.down
    change_table 'tracks' do |t|
      t.remove_index :title
      t.remove_index :artist
      t.remove_index :album
    end
  end
end

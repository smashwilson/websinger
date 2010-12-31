class CreateEnqueuedTracks < ActiveRecord::Migration
  def self.up
    create_table :enqueued_tracks do |t|
      t.integer :position
      t.integer :track_id

      t.timestamps
    end
  end

  def self.down
    drop_table :enqueued_tracks
  end
end

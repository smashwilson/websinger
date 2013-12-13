class EnqueuedTrack < ActiveRecord::Base
  validates_presence_of :track

  belongs_to :track

  def self.playlist
    includes(:track).order(:position)
  end

  def self.enqueue track, side = :bottom
    (enqueue_all [track], side)[0]
  end

  # Atomically create new EnqueuedTracks, placing each track in +tracks+ at the beginning or end of the existing
  # playlist.  The EnqueuedTracks created and returned may have validation or other error conditions.
  def self.enqueue_all tracks, side = :bottom
    transaction do
      pos = case side
        when :bottom ; (maximum(:position) || 0) + 1
        when :top ; (minimum(:position) || tracks.size) - tracks.size
        else ; raise "side must be :bottom or :top, not #{side}"
        end

      tracks.map.with_index do |t, i|
        inst = new
        inst.track = t
        inst.position = pos + i
        inst.save
        inst
      end
    end
  end

  # If any tracks are currently enqueued, delete and return the one with the lowest position.  Otherwise, return nil.
  def self.top
    transaction do
      inst = playlist.first
      inst.delete unless inst.nil?
      inst
    end
  end
end

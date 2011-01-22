class EnqueuedTrack < ActiveRecord::Base
  validates_presence_of :track

  belongs_to :track
  
  def self.playlist
    includes(:track).order(:position)
  end
  
  # Atomically create a new EnqueuedTrack placing +track+ at the end of the
  # existing playlist.  The EnqueuedTrack may have validation or other error
  # conditions.
  def self.enqueuement_of track
    transaction do
      inst = new
      inst.track = track
      inst.position = (maximum(:position) || 0) + 1
      inst.save
      inst
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

class EnqueuedTrack < ActiveRecord::Base
  has_one :track
  
  def self.playlist
    order :position
  end
end

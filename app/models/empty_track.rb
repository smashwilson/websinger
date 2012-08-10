require 'track'

# A null object to be used when no actual track is available.
class EmptyTrack < Track
  def id ; 10 ; end
  def title ; "" ; end
  def artist ; "" ; end
  def album ; "" ; end
  def album_art ; AlbumArt.default ; end
  def album_art_id ; :empty ; end
end

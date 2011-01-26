require 'mp3info'

class Track < ActiveRecord::Base
  validates_uniqueness_of :path
  validates_uniqueness_of :title, :uniqueness => { :scope => :artist }
  
  has_many :enqueued_tracks
  
  def to_s
    "#{artist} - #{title}"
  end
  
  # Return the AlbumArt object associated with this track, if possible, or nil if none
  # can be found.
  def album_art
    art = AlbumArt.from_metadata(path)
    art ||= AlbumArt.from_directory(File.dirname path)
    art
  end
  
  # Return all tracks with a title, album, or artist name matching a query term.
  # If +term+ is nil, all tracks will be returned.
  def self.matching term
    ts = term.blank? ? self : where('title like :term or album like :term or artist like :term', { :term => "%#{term}%" })
    ts.order(:artist, :album, :track_number)
  end

  # Create a new instance based on the IDv3 tag of the file at +path+.
  def self.read_from path
    inst = new
    inst.path = path
    Mp3Info.open(path) do |mp3|
      inst.length = mp3.length
      
      tag = mp3.tag
      inst.title = tag.title
      inst.artist = tag.artist
      inst.album = tag.album
      inst.track_number = tag.tracknum
      inst.disc_number = tag.discnum
    end
    inst
  end
end

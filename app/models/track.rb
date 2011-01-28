require 'mp3info'

class Track < ActiveRecord::Base
  validates_uniqueness_of :path
  validates_uniqueness_of :title, :scope => [:artist, :album]
  validates_presence_of :title

  has_many :enqueued_tracks
  
  def to_s
    "#{artist} - #{title}"
  end

  # Return the AlbumArt object associated with this track, if possible, or nil if none
  # can be found.
  def album_art
    art = Mp3Info.open(path) { |mp3| art = AlbumArt.from_metadata(mp3) }
    art ||= AlbumArt.from_directory(File.dirname path)
    art
  end
  
  def update_from_path p
    self.path = p
    Mp3Info.open(p) do |mp3|
      self.length = mp3.length

      tag = mp3.tag
      self.title = tag.title

      self.artist = tag.artist
      self.artist_slug = self.artist.to_url if self.artist

      self.album = tag.album
      self.album_slug = self.album.to_url if self.album

      self.track_number = tag.tracknum
      self.disc_number = tag.discnum
    end
  end

  # Return all tracks with a title, album, or artist name matching a query term.
  # If +term+ is nil, all tracks will be returned.
  def self.matching term
    ts = term.blank? ? self : where('title like :term or album like :term or artist like :term', { :term => "%#{term}%" })
    ts.order(:artist, :album, :track_number)
  end

  # Return all tracks in the specified album, ordered by track number.
  def self.in_album artist_slug, album_slug
    where(:artist_slug => artist_slug, :album_slug => album_slug).order(:track_number)
  end
end

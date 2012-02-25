require 'mp3info'
require 'randumb'

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
    art = AlbumArt.from_directory(File.dirname(path))
    if art.nil?
      Mp3Info.open(path) { |mp3| art = AlbumArt.from_metadata(mp3) }
    end
    art
  end

  def update_from_path p
    self.path = p
    rencode = lambda do |original|
      next nil if original.nil?
      str = original.encode('utf-8', :invalid => :replace, :undef => :replace)
      str.gsub!("\x00", "")
      next nil if str.empty?
      str
    end

    Mp3Info.open(p) do |mp3|
      self.length = mp3.length

      tag = mp3.tag
      self.title = rencode.call(tag.title)

      self.artist = rencode.call(tag.artist)
      self.artist_slug = self.artist ? self.artist.to_url : nil

      self.album = rencode.call(tag.album)
      self.album_slug = self.album ? self.album.to_url : nil

      self.track_number = tag.tracknum

      tag2 = mp3.tag2
      self.disc_number = tag2['TPOS']
    end
  end

  # Return all tracks with a title, album, or artist name matching a query term.
  def self.matching term
    where('title like :term or album like :term or artist like :term', { :term => "%#{term}%" }).order(:artist, :album, :track_number)
  end

  # Choose a ramdom selection of #per_page sample tracks.
  def self.sample
    random(per_page)
  end

  # Return all tracks in the specified album, ordered by track number.
  def self.in_album artist_slug, album_slug
    where(:artist_slug => artist_slug, :album_slug => album_slug).order(:track_number)
  end

  # The number of results to display at once.
  def self.per_page
    20
  end

end

require 'mp3info'

class Track < ActiveRecord::Base
  validates_uniqueness_of :path
  validates_uniqueness_of :title, :uniqueness => { :scope => :artist }
  
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

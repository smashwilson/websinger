require 'filemagic'

# A non-ActiveRecord model.  Instances are constructed on demand from Track objects.
class AlbumArt
  attr_accessor :image, :mime_type

  def initialize image, mime_type
    @image, @mime_type = image, mime_type
  end
  
  FilenamePatterns = [
    'AlbumArt*.jpg','[Cc]over.jpg','[Cc]over.png',
    '[Ff]older.jpg', 'Folder.jpg'
  ]
  
  # Create a new instance based on the contents and inferred mime type of the file
  # at +path+.
  def self.from_file path
    mime_type = 'image/' + FileMagic.open { |fm| fm.file(path, :mime) }
    new File.open(path) { |f| f.gets(nil) }, mime_type
  end
  
  # Create a new instance from album art embedded in the mp3 metadata of a track.
  def self.from_metadata metadata
    tag2 = mp3.tag2
    return nil unless tag2
    apic = tag2.APIC
    return nil unless apic
      
    data = apic.unpack('c Z* c Z* a*')
    new data[4], data[1]
  end
  
  def self.from_directory dirname
    FilenamePatterns.each do |pattern|
      Dir[File.join(dirname, pattern)].each do |path|
        return from_file(path) if File.readable? path
      end
    end
    nil
  end
end

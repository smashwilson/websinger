# encoding: ASCII-8BIT

# A non-ActiveRecord model.  Instances are constructed on demand from Track objects.
class AlbumArt
  attr_accessor :image, :mime_type

  def initialize image, default = false
    @image = image
    @default = default

    # Infer the image mimetype by looking for magic numbers within the image data. For references:
    # http://en.wikipedia.org/wiki/Magic_number_(programming)
    if @image.start_with?("\xFF\xD8") && @image.end_with?("\xFF\xD9")
      @mime_type = "image/jpeg"
    elsif @image.start_with?("GIF89a") || @image.start_with?("GIF87a")
      @mime_type = "image/gif"
    elsif @image.start_with?("\x89PNG\r\n\x1A\n")
      @mime_type = "image/png"
    elsif @image.start_with?("II\x2A\x00") || @image.start_with?("MM\x00\x2A")
      @mime_type = "image/tiff"
    end
  end

  # Return true if the image is non-empty and a mime type was successfully inferred.
  def ok?
    !@image.nil? && !@mime_type.nil?
  end

  # Return true if this is the "placeholder" image for albums without album art.
  def default?
    @default
  end

  FilenamePatterns = [
    'AlbumArt*.jpg','[Cc]over.jpg','[Cc]over.png',
    '[Ff]older.jpg', '[Ff]older.png'
  ]

  # Create a new instance based on the contents and inferred mime type of the file
  # at +path+.
  def self.from_file path, default = false
    new(File.open(path, 'rb:BINARY') { |f| f.read nil }, default)
  end

  # Create a new instance from album art embedded in the mp3 metadata of a track.
  def self.from_metadata metadata
    tag2 = metadata.tag2
    return nil unless tag2
    apic = tag2.APIC
    return nil unless apic

    data = apic.unpack('c Z* c Z* a*')
    new data[4]
  end

  def self.from_directory dirname
    FilenamePatterns.each do |pattern|
      Dir[File.join(dirname, pattern)].each do |path|
        next unless File.readable? path
        art = from_file(path)
        return art if art.ok?
      end
    end
    nil
  end

  def self.default
    @default ||= from_file(Rails.root.join('app', 'assets', 'images', 'missing-album.png'), true)
  end
end

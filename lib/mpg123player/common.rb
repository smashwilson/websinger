module Mpg123Player

module Configuration
  class << self
    attr_accessor :player_path, :user
    attr_accessor :base_path, :pid_path, :status_path, :log_path, :error_log_path
    attr_accessor :command_poll, :command_timeout
  end
end

module Configurable
  attr_accessor :log_path, :error_log_path

  def configure
    @player_path = Configuration.player_path || '/usr/bin/mpg123'
    @base_path = Configuration.base_path || Rails.root.join('tmp')
    @status_path = Configuration.status_path || @base_path.join('status.yaml')
    @pid_path = Configuration.pid_path || @base_path.join('pids', 'player.pid')
    @log_path = Configuration.log_path || Rails.root.join('log', 'player.log')
    @error_log_path = Configuration.error_log_path || Rails.root.join('log', 'player.err.log')
    @command_poll = (Configuration.command_poll || 0.1).to_f
    @command_timeout = (Configuration.command_timeout || 5).to_f
  end
end

Commands = %q{play pause jump volume restart skip stop shutdown}

class Status
  attr_accessor :playback_state, :error
  attr_accessor :artist, :album, :title, :length, :track_id
  attr_accessor :seconds, :volume

  attr_accessor :track

  def initialize
    @playback_state = :playing
    @seconds = 0
    @volume = 100
  end

  # Update this status object to reflect that +track+ is now playing, reseting playback progress.
  def on_track track
    @track = track
    @track_id = track.id
    @artist = track.artist
    @album = track.album
    @title = track.title
    @length = track.length
    @seconds = 0
  end

  def clear
    @artist = @album = @title = @track_id = @track = nil
    @seconds = 0
    @length = 1
    @volume = 100
    @error = nil
  end

  # Determine whether or not this Status has changed sufficiently from +other+ to justify rewriting it to disk.
  def is_close_to? other
    return false if other.nil?
    return false unless @playback_state == other.playback_state
    return false unless @artist == other.artist
    return false unless @album == other.album
    return false unless @title == other.title
    return false unless @length == other.length
    return false unless @track_id == other.track_id
    return false unless @volume == other.volume
    return false unless @error == other.error

    return false unless (@seconds - other.seconds).abs < 1

    true
  end

  # Generate a consistent textual description of progress within the track, formatted as "MM:SS / MM:SS".
  def progress_text
    return "" unless @track_id
    "#{format_seconds(@seconds)} / #{format_seconds(@length)}"
  end

  # Convert this Status object to a Hash for conversion to JSON.
  def to_hash
    { :playback_state => @playback_state,
      :error => @error,
      :artist => @artist,
      :album => @album,
      :title => @title,
      :track_id => @track_id,
      :seconds => @seconds,
      :length => @length,
      :progress_text => progress_text,
      :volume => @volume }
  end

  def self.stopped
    inst = new
    inst.playback_state = :stopped
    inst.clear
    inst
  end

  def self.from hash
    inst = new
    hash.each do |k,v|
      inst.send("#{k}=".to_sym, v) if inst.respond_to? "#{k}="
    end
    inst
  end

  protected

  def format_seconds seconds
    minutes = (seconds / 60.0).floor
    remaining = (seconds - (minutes * 60)).floor
    trailing = if remaining < 10 then '0' else '' end
    "#{minutes}:#{trailing}#{remaining}"
  end

end

end

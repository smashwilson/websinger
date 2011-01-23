module Mpg123Player

module Configuration  
  class << self
    def player_path ; @player_path || '/usr/bin/mpg123' ; end
    def pid_path ; @pid_path || '/var/websinger/player.pid' ; end
    def status_path ; @status_path || '/var/websinger/status.yaml' ; end
    def server_port ; @server_port || 12340 ; end
    
    def player_path= path ; @player_path = path ; end
    def pid_path= path ; @pid_path = path ; end
    def status_path= path ; @status_path = path ; end
    def server_port= port ; @server_port = port ; end
  
    def base_path= path
      @status_path = "#{path}/status.yaml"
      @pid_path = "#{path}/player.pid"
    end
  end
end

module Configurable
  
  def configure
    @player_path = Configuration.player_path
    @status_path = Configuration.status_path
    @pid_path = Configuration.pid_path
    @server_port = Configuration.server_port
  end
end

Commands = ['play', 'pause', 'stop', 'shutdown']

class Status
  attr_accessor :title, :artist, :album, :track_number, :track_id
  attr_accessor :seconds, :track_length, :volume
  
  attr_accessor :track
  
  attr_accessor :playback_state
  
  def initialize
    @playback_state = :playing
    @seconds = 0
    @volume = 0
  end
  
  def percent_complete
    @track ? (@seconds / @track.length) * 100 : 0
  end
  
  def progress_s
    @track ? "#{to_minutes_s @seconds} / #{to_minutes_s @track.length}" : '0:00 / 0:00'
  end
  
  def clear
    @title = @artist = @album = @track_number = @track_id = nil
    @seconds = 0
  end
  
  def is_close_to? other
    return false unless @title == other.title
    return false unless @artist == other.artist
    return false unless @album == other.album
    return false unless @track_number == other.track_number
    return false unless @track_id == other.track_id
    return false unless @volume == other.volume
    return false unless @playback_state == other.playback_state
    
    return false unless (@seconds - other.seconds) < 1
    
    true
  end
  
  def to_hash
    { :playback_state => @playback_state,
      :artist => @artist,
      :album => @album,
      :title => @title,
      :track_number => @track_number,
      :track_id => @track_id,
      :seconds => @seconds,
      :volume => @volume,
      :progress => progress_s,
      :percent_complete => percent_complete }
  end
  
  protected

  def to_minutes_s seconds
    minutes = seconds.to_i / 60
    "#{minutes}:#{(seconds - minutes * 60).to_i.to_s.rjust(2, '0')}"
  end
  
  public
  
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
end

end

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

class Status
  attr_accessor :title, :artist, :album, :track_number, :track_id
  attr_accessor :seconds, :volume
  
  attr_accessor :playback_state
  
  def initialize
    @playback_state = :playing
    @seconds = 0
    @volume = 0
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
  
  def self.stopped
    inst = new
    inst.playback_state = :stopped
    inst.clear
    inst
  end
end

end

require 'gserver'
require 'thread'

require 'mpg123player/common'

module Mpg123Player

class Server < GServer
  include Configurable

  attr_accessor :stay_stopped, :shutting_down
  attr_accessor :status, :last_status
  
  def initialize
    configure
  
    super(@server_port)
    stdlog = $stdout
    
    @mutex = Mutex.new
    @stay_stopped = false
    @shutting_down = false
    @status = Status.new
    @last_status = @status.dup
    
    @on_launch = Proc.new { }
    @on_stop = Proc.new { }
    @on_status = Proc.new { |status| }
    
    check_paths
  end
  
  # Configuration
  
  def advance &block
    @on_launch = block
    @on_stop = block
  end
  
  def on_status &block
    @on_status = block
  end
  
  # Controls
  
  def load_track track_path, track_id = nil
    @mutex.synchronize do
      @status.track_id = track_id
      @status.playback_state = :playing
      @pipe.puts "L #{track_path}"
    end
  end
  
  def play_track
    @mutex.synchronize do
      @stay_stopped = false
      @pipe.puts 'P' if @status.playback_state == :paused
    end
  end
  
  def pause_track
    @mutex.synchronize { @pipe.puts 'P' if @status.playback_state != :paused }
  end
  
  def stop_track
    @mutex.synchronize do
      @stay_stopped = true
      @pipe.puts 'S' if @status.playback_state != :stopped
    end
  end

  # Request handling
    
  def serve io
    case io.gets.chomp
    when 'play' ; play_track
    when 'pause' ; pause_track
    when 'stop' ; stop_track
    when 'shutdown' ; stop
    else io.puts 'E: Unrecognized command'
    end
    io.close
  end
  
  # State control

  def start
    File.open(@pid_path, 'w') { |f| f.puts Process.pid }
    start_player
    super
    @on_launch.call
  end
  
  def join
    super
    @parsing_thread.join
  end
  
  def stop
    @shutting_down = true
    super
    Process.kill 'TERM', @pipe.pid
    @pipe.close
    File.delete(@pid_path, @status_path)
  end
  
  #
  # Internal utilities.
  #
  
  protected
  
  # Verify that the locations specified for the pid and status files exists and is writable.
  def check_paths
    [@status_path, @pid_path].each do |path|
      unless Dir.exist?(File.dirname(path)) && (! File.exist?(path) || File.writable?(path))
        $stderr.puts <<MSG
Unable to create the file: <#{path}>

Please ensure that the directory exists and that your filesystem permissions are set appropriately, or
change the locations with Mpg123Player::Configuration.
MSG
        raise
      end
    end
  end
  
  # Open a pipe to the player executible.  Launch the parsing loop in a background thread.
  def start_player
    @pipe = IO.popen("#{@player_path} -R -", 'w+')
    @parsing_thread = Thread.new { process_line(@pipe.gets) until @pipe.eof? || @shutting_down }
  end
  
  # Parse MPG123 remote interface output.
  # For documentation, see http://mpg123.org/cgi-bin/viewvc.cgi/trunk/doc/README.remote
  def process_line line
  
    # Startup version message.
    return if line =~ /^@R MPG123/
    
    # Stream information that we don't care about.
    return if line =~ /^@S /
  
    # ID3v2 metadata tags
    if md = /^@I ID3v2.([^:]+):(.+)/.match(line)
      if @status.respond_to? md[1]
        @status.perform(md[1], md[2].strip)
        update_status
      else
        puts "Ignoring tag: #{md[1]}"
      end
      return
    end
    
    # ID3 tag
    if md = /^@I ID3:(.{30})(.{30})(.{30})/.match(line)
      @status.title = md[1].strip
      @status.artist = md[2].strip
      @status.album = md[3].strip
      update_status
      return
    end
    
    # ID3 optional metadata
    if md = /^@I ID3\.track:(.+)/.match(line)
      @status.track_number = md[1].to_i
      update_status
      return
    end
    
    # In the absense of parseable ID3 data
    if md = /^@I (.+)/.match(line)
      @status.title = md[1]
      update_status
      return
    end
    
    # Frame info (during playback)
    if md = /^@F [0-9-]+ [0-9-]+ ([0-9.-]+) ([0-9.-]+)/.match(line)
      @status.seconds = md[1].to_f
      update_status
      return
    end
    
    # Playing status changed
    if md = /^@P (\d+)/.match(line)
      transition_to_state([:stopped, :paused, :playing][md[1].to_i])
      return
    end
    
    # Error
    if md = /^@E (.+)/.match(line)
      puts "! #{md[1]}"
      return
    end
    
    # Volume
    if md = /^@V (\d+)/.match(line)
      @status.volume md[1].to_i
      return
    end
    
    # Unparsed!
    puts "UNPARSED #{line}"
  end
  
  # Invoke the appropriate callbacks depending on the current and previous player states.
  def transition_to_state playback_state
    former = @status.playback_state
    if former != playback_state
      @mutex.synchronize { @status.playback_state = playback_state }
      @status.clear if playback_state == :stopped
      update_status
      @on_stop.call if playback_state == :stopped
    end
  end
  
  def update_status
    unless @status.is_close_to? @last_status
      @on_status.call(@status)
      File.open(@status_path, 'w') { |f| f.puts @status.to_json }
      @last_status = @status.dup
    end
  end
end

end

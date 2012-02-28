# Requires an ActiveRecord environment.

require 'io/wait'
require 'logger'

require 'mpg123player/common'
require 'active_support/json'

module Mpg123Player

class Player
  include Configurable
  include ActiveSupport::BufferedLogger::Severity

  attr_accessor :poll_time
  attr_accessor :status, :last_status
  attr_accessor :shutting_down

  def initialize poll_time = 1, log_level = Logger::INFO
    configure
    check_paths

    @poll_time = 1 # Seconds, may be fractional
    @status = Status.new
    @last_status = @status.dup
    @shutting_down = false

    # Initialize the logger.
    @logger = Logger.new(@log_path, 1, 1024 * 1024)
    @logger.level = log_level
  end

  # Lifecycle events.

  # Open a pipe to the player executible and start the parsing loop. Only return once a shutdown command is processed.
  def main_loop
    @logger.info 'Starting player.'
    @pipe = IO.popen("#{@player_path} -R -", 'w+')

    # Record the player pid. Also, be sure that the player will be SIGTERM'd if we are.
    File.open(@pid_path, 'w') { |f| f.puts @pipe.pid }
    Signal.trap('TERM') { Process.kill 'TERM', @pipe.pid }

    # Load the first track, or wait for the first track to be enqueued.
    advance

    # Cycle until a shutdown command is received.
    until @shutting_down
      process_line(@pipe.gets) if @pipe.ready?
      process_command_queue
    end

    # Kill the mpg123 process.
    Process.kill 'TERM', @pipe.pid

    @logger.info 'Stopping player.'
    @logger.close
  end

  # A track finished. Load the next enqueued track, waiting for one to be enqueued if the queue is empty.
  def advance
    e = EnqueuedTrack.top
    while e.nil? && !@shutting_down
      @logger.debug 'Waiting for track'
      sleep @poll_time
      e = EnqueuedTrack.top
      process_command_queue
    end
    load_track(e.track) unless @shutting_down
  end

  # Player process controls.

  def load_track t, state = :playing
    @status.track_id = t.id
    @status.playback_state = state
    @status.seconds = 0

    command = state == :playing ? 'L' : 'LP'
    execute "#{command} #{t.path}"

    update_status
  end

  def play_action
    execute 'P' if @status.playback_state != :playing
  end

  def pause_action
    execute 'P' if @status.playback_state != :paused
  end

  # TODO remove when player controls are reorganized.
  def stop_action
    execute 'S' if @status.playback_state != :stopped
  end

  # Jump to an absolute track position in seconds.
  def jump_action seconds
    unless seconds =~ /[0-9]+/
      @logger.error "Invalid jump offset: #{seconds}"
      return
    end
    if [:playing, :paused].include?(@status.playback_state)
      execute "J #{seconds}s"
      @status.seconds = seconds.to_f
      update_status
    end
  end

  # Set player volume as a percent, 0 to 100.
  def volume_action percent
    unless percent =~ /100|[0-9]?[0-9]/
      @logger.error "E Invalid volume: #{percent}"
      return
    end
    execute "V #{percent}"
  end

  # Restart the current track.
  def restart_action
    execute "J 0"
    update_status
  end

  # Skip to the next enqueued track, if one is present. Do nothing if the queue is empty.
  def skip_action
    e = EnqueuedTrack.top
    load_track(e.track, @status.playback_state) unless e.nil?
  end

  # Unload the track and stop the current player.
  def shutdown_action
    execute 'Q'
    @shutting_down = true
  end

  protected

  # Verify that the locations specified for the pid and status files exist and are writable.
  def check_paths
    [@status_path, @pid_path].each do |path|
      unless Dir.exist?(File.dirname(path)) && (! File.exist?(path) || File.writable?(path))
        @logger.fatal <<MSG
Unable to create the file: <#{path}>

Please ensure that the directory exists and that your filesystem permissions are set appropriately, or
change the locations with Mpg123Player::Configuration.
MSG
        raise
      end
    end
  end

  # Parse MPG123 remote interface output.
  # For documentation, see http://mpg123.org/cgi-bin/viewvc.cgi/tags/1.2.1/doc/README.remote
  def process_line line
    @logger.debug line

    # EOF from pipe.
    return if line.nil?

    # Startup version message.
    return if line =~ /^@R MPG123/

    # Stream information that we don't care about.
    return if line =~ /^@S /

    # Jump feedback.
    return if line =~ /^@J/

    # ID3v2 metadata tags
    if md = /^@I ID3v2.([^:]+):(.+)/.match(line)
      getter, setter = md[1], "#{md[1]}="
      if @status.respond_to?(setter) && @status.respond_to?(getter)
        @status.send(setter, md[2].strip) if @status.send(getter).nil?
        update_status
      else
        @logger.debug "Ignoring tag: #{getter}"
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

    # In the absense of parseable ID3 data just grab whatever
    if md = /^@I (.+)/.match(line)
      @status.title ||= md[1]
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
      @logger.error md[1]
      return
    end

    # Volume
    if md = /^@V (\d+)/.match(line)
      @status.volume = md[1].to_i
      update_status
      return
    end

    # Unparsed!
    @logger.warn "UNPARSED #{line}"
  end

  # Handle all enqueued PlayerCommands.
  def process_command_queue
    Rails.logger.silence(WARN) do
      PlayerCommand.flush_queue.each { |c| process_command c }
    end
  end

  # Handle an incoming PlayerCommand.
  def process_command command
    @logger.info "Received command #{command.action} #{command.parameter}"
    handler = method("#{command.action}_action")
    case handler.arity
    when 0 ; handler.call
    when 1 ; handler.call(command.parameter)
    else ; @logger.error "Action method #{command.action}_action has arity of #{handler.arity}"
    end
  end

  # Invoke the appropriate callbacks depending on the current and previous player states.
  def transition_to_state playback_state
    former = @status.playback_state
    @logger.info "Transitioning from state #{former} to #{playback_state}"
    if former != playback_state
      @status.playback_state = playback_state
      @status.clear if playback_state == :stopped
      update_status
    end
    advance if playback_state == :stopped
  end

  # Serialize the Status object to disk as JSON if it has changed significantly.
  def update_status
    unless @status.is_close_to? @last_status
      File.open(@status_path, 'w') { |f| f.puts @status.to_json }
      @last_status = @status.dup
    end
  end

  # Send a command to the mpg123 pipe.
  def execute string
    @logger.debug "> #{string}"
    @pipe.print "#{string}\n"
  end

end

end

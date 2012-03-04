# Requires an ActiveRecord environment.

require 'io/wait'
require 'logger'

require 'mpg123player/common'
require 'mpg123player/server'
require 'active_support/json'

module Mpg123Player

# Server process that plays enqueued tracks by sending commands through a pipe to an mpg123 child process.
class ProductionServer < Server

  def create_logger
    Logger.new(@log_path, 1, 1024 * 1024)
  end

  # Lifecycle events.

  # Open a pipe to the player executable and start the parsing loop. Only return once a shutdown command is processed.
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

  def load_track t, state = :playing
    command = state == :playing ? 'L' : 'LP'
    execute "#{command} #{t.path}"
    super(t, state)
  end

  # Actions.

  def play_action
    execute 'P' if @status.playback_state != :playing
  end

  def pause_action
    execute 'P' if @status.playback_state != :paused
  end

  # Jump to an absolute track position, specified in seconds.
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

  # Skip to the next enqueued track, if one is present. Stop playback if the queue is empty.
  def skip_action
    e = EnqueuedTrack.top
    if e.nil?
      execute 'S'
    else
      load_track(e.track, @status.playback_state)
    end
  end

  # Unload the track and stop the current player.
  def shutdown_action
    execute 'Q'
    @shutting_down = true
  end

  protected

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

    # ID3v2 metadata tags. We pull track data from ActiveRecord instead.
    return if line =~ /^@I/

    # Frame info (during playback).
    if md = /^@F [0-9-]+ [0-9-]+ ([0-9.-]+) ([0-9.-]+)/.match(line)
      @status.seconds = md[1].to_f
      update_status
      return
    end

    # Playing status changed.
    if md = /^@P (\d+)/.match(line)
      transition_to_state([:stopped, :paused, :playing][md[1].to_i])
      return
    end

    # Error.
    if md = /^@E (.+)/.match(line)
      @logger.error md[1]
      return
    end

    # Volume change.
    if md = /^@V (\d+)/.match(line)
      @status.volume = md[1].to_i
      update_status
      return
    end

    # Unparsed!
    @logger.warn "UNPARSED #{line}"
  end

  # Send a command to the mpg123 pipe.
  def execute string
    @logger.debug "> #{string}"
    @pipe.print "#{string}\n"
  end

end

end

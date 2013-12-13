# Requires an ActiveRecord environment.

require 'io/wait'
require 'logger'

require 'mpg123player/common'
require 'active_support/json'

module Mpg123Player

# Superclass of daemon processes that consume tracks from EnqueuedTracks and commands from PlayerCommands.
class Server
  include Configurable
  include ActiveSupport::BufferedLogger::Severity

  attr_accessor :poll_time
  attr_accessor :status, :last_status
  attr_accessor :shutting_down

  def initialize poll_time = 1, log_level = Logger::INFO
    configure

    # Initialize the logger.
    @logger = create_logger
    @logger.level = log_level
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.strftime('%d %b %Y %I:%M:%S %p')} #{severity.rjust 5} | #{msg.to_s}\n"
    end

    check_paths

    @poll_time = 1 # Seconds, may be fractional
    @status = Status.stopped
    @shutting_down = false

    update_status
  end

  def create_logger
    raise '#create_logger not implemented'
  end

  # Lifecycle events.

  # The main process loop. Only return after a shutdown command is received.
  def main_loop
    raise '#main_loop not implemented'
  end

  # A track finished. Load the next enqueued track, waiting for one to be enqueued if the queue is empty.
  def advance
    e = EnqueuedTrack.top
    while e.nil? && !@shutting_down
      @status.clear
      update_status

      @logger.debug 'Waiting for track.'
      sleep @poll_time
      e = EnqueuedTrack.top
      process_command_queue
    end
    load_track(e.track) unless @shutting_down
  end

  # Player process controls.

  # Override to perform actual track loading, then call super.
  def load_track t, state = :playing
    @logger.info "Loading track #{t.to_s} in state #{state}."

    @status.on_track t
    @status.playback_state = state
    update_status
  end

  def play_action
    # Override to handle play action.
  end

  def pause_action
    # Override to handle pause action.
  end

  def jump_action seconds
    # Override to handle jump action.
  end

  def volume_action percent
    # Override to handle volume action.
  end

  def restart_action
    # Override to handle restart action.
  end

  def skip_action
    # Override to handle skip action.
  end

  def shutdown_action
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
    @logger.info "Transitioning from state #{former} to #{playback_state}."
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

end

end

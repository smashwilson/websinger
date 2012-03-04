# Requires an ActiveRecord context.

require 'mpg123player/common'
require 'mpg123player/server'
require 'logger'

module Mpg123Player

# The fake back-end used to support the DevelopmentClient. Launches a single background thread that emulates
# progressing through the queue like the real Server, including consuming and responding to PlayerCommands.
class DevelopmentServer < Server
  include ActiveSupport::BufferedLogger::Severity

  def create_logger
    Logger.new(STDOUT)
  end

  def main_loop
    @logger.info "Entering main loop."

    # Record the player pid (of this process).
    File.open(@pid_path, 'w') { |f| f.puts  Process.pid }

    advance
    until @shutting_down
      play_track
      process_command_queue
    end
    @logger.info "Shutting down."
  end

  # Advance the playing of the current track by a single second.
  def play_track
    return if @status.playback_state == :paused
    @logger.debug "Playing track: #{@status.seconds} out of #{@status.length}"
    sleep 1
    @status.seconds += 1
    update_status
    if @status.seconds >= @status.length
      @logger.debug "Track complete. Advancing to next."
      @status.clear
      @status.playback_state = :stopped
      update_status
      advance
    end
  end

  # Fake commands that just manipulate the status directly.

  def play_action
    @status.playback_state = :playing
    update_status
  end

  def pause_action
    @status.playback_state = :paused
    update_status
  end

  def jump_action seconds
    @status.seconds = seconds.to_f
    update_status
  end

  def volume_action percent
    @status.volume = percent.to_f
    update_status
  end

  def restart_action
    @status.seconds = 0
    update_status
  end

  def skip_action
    advance
  end

  def shutdown_action
    @shutting_down = true
  end

end

end

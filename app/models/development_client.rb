# This client is for interactive development mode (even on the same system that the real websinger-player is running
# on.) It simulates the "playing" of music and advancement through tracks in real-time with a background thread, but
# doesn't actually produce any audio.
class DevelopmentClient < Client

  def status
    self.class.status
  end

  class << self
    @status ||= Mpg123Player::Status.stopped
    @shutting_down ||= false

    def status ; @status ; end

    Thread.new { main_loop }

    def main_loop
      advance
      until @shutting_down
        play_track
        process_command_queue
      end
    end

    def advance
      e = EnqueuedTrack.top
      while e.nil? && !@shutting_down
        sleep 0.5
        e = EnqueuedTrack.top
        process_command_queue
      end
      load_track(e.track) unless @shutting_down
    end

    def load_track t, state = :playing
      @status.on_track t
      @status.playback_state = state
    end

    # Advance the playing of the current track by a single second.
    def play_track
      return if @status.playback_state = :paused
      sleep 1
      @status.seconds += 1
      if @status.seconds >= @status.length
        @status.playback_state = :stopped
        advance
      end
    end

    # Consume commands from the command queue.
    def process_command_queue
      Rails.logger.silence(WARN) do
        PlayerCommand.flush_queue.each { |c| process_command c }
      end
    end

    # Handle a specific command.
    def process_command command
      handler = method("#{command.action}_action")
      case handler.arity
      when 0 ; handler.call
      when 1 ; handler.call(command.parameter)
      else ; raise "Action method #{command.action}_action has arity of #{handler.arity}"
      end
    end

    # Fake commands that just manipulate the status directly.

    def play_action
      @status.playback_state = :playing
    end

    def pause_action
      @status.playback_state = :paused
    end

    def jump_action seconds
      @status.seconds = seconds.to_f
    end

    def volume_action percent
      @status.volume = percent.to_f
    end

    def restart_action
      @status.seconds = 0
    end

    def skip_action
      e = EnqueuedTrack.top
      if e.nil?
        @status.playback_state = :stopped
      else
        load_track e.track, @status.playback_state
      end
    end

    def shutdown_action
      @shutting_down = true
    end

  end
end

require 'mpg123player/common'
require 'active_support/json'

# Non-ActiveRecord model. Manage status and communications with the mpg123 player process.
class Client
  include Mpg123Player
  include Configurable
  include ActiveSupport::BufferedLogger::Severity

  attr_accessor :asynchronous
  attr_reader :error

  def initialize
    configure
    @asynchronous = false
  end

  # Issue a command to the server and wait for the remote process to handle it, within the currently configured
  # +command_timeout+.
  def command string, parameter = nil
    cmd = PlayerCommand.create!(:action => string, :parameter => parameter)
    return if @asynchronous

    Rails.logger.silence(WARN) do
      wait_time = 0
      until wait_time >= @command_timeout
        wait_time += sleep(@command_poll)
        return unless PlayerCommand.exists?(cmd.id)
      end
    end

    # Timed out waiting for command acceptance
    @error = "Timed out submitting command #{string}."
  end

  # Status

  # Query the current player status, setting +error+ and returning false if something is wrong.
  def ok?
    unless File.readable?(@pid_path)
      @error = "Can't read the pid file at #{@pid_path}!"
      return false
    end
    pid = File.open(@pid_path) { |f| f.gets(nil) }.to_i
    Process.kill(0, pid)
  rescue Errno::ESRCH => e
    @error = "The server died!"
    false
  rescue Errno::EPERM => e
    @error = "Someone else is running the server!"
    false
  else
    true
  end

  # Populate the Status object by reading the JSON written to disk by the server process, amending it with our local
  # +error+ if one is present.
  def status
    @status ||= if File.readable?(@status_path)
      Status.from(JSON(File.read(@status_path)))
    else
      Status.stopped
    end
    @status.error = @error
    @status
  end

  def playing?
    status.playback_state == 'playing'
  end

  def paused?
    status.playback_state == 'paused'
  end

  def stopped?
    status.playback_state == 'stopped'
  end

end

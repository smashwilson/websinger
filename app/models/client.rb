require 'mpg123player/common'
require 'active_support/json'

# Non-ActiveRecord model. Manage status and communications with the mpg123 player process.
class Client
  include Mpg123Player
  include Configurable

  attr_reader :error

  def initialize
    configure
  end

  # Controls

  def play ; command 'play' ; end
  def pause ; command 'pause' ; end
  def volume percent ; command 'volume', percent ; end
  def restart ; command 'restart' ; end
  def skip ; command 'skip' ; end
  def stop ; command 'stop' ; end
  def shutdown ; command 'shutdown' ; end

  # Issue a command to the server. Return the command object.
  def command string, parameter = nil
    PlayerCommand.create!(:action => string, :parameter => parameter)
  end

  # Status

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

  def status
    @status ||= Status.from(JSON(status_json))
  end

  def status_json
    if File.exist?(@status_path)
      File.open(@status_path) { |f| f.gets(nil) }
    else
      Status.stopped.to_json
    end
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

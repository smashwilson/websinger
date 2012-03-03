require 'active_support/json'

# Client implementation for use in production. This Client actually communicates with a remote Mpg123player::Server
# process, lauched with `rake websinger:player`, and results in actual music playing over the speakers.
class ProductionClient < Client

  # Issue a command to the server and wait for the remote process to handle it, within the currently configured
  # +command_timeout+.
  def command string, parameter = nil
    cmd = PlayerCommand.create!(:action => string, :parameter => parameter)

    Rails.logger.silence(WARN) do
      wait_time = 0
      until wait_time >= @command_timeout
        wait_time += sleep(@command_poll)
        return true unless PlayerCommand.exist?(cmd.id)
      end
    end

    # Timed out waiting for command acceptance
    false
  end

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

end

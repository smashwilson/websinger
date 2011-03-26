require 'socket'

require 'mpg123player/common'
require 'active_support/json'

module Mpg123Player

class Client
  include Configurable
  
  attr_reader :error

  def initialize
    configure
  end
  
  # Controls
  
  def play ; command 'play' ; end
  def pause ; command 'pause' ; end
  def stop ; command 'stop' ; end
  def shutdown ; command 'shutdown' ; end

  # Connect to the server, issue a command, and disconnect.
  def command string
    unless Commands.include? string
      @error = "Invalid command: #{string}"
      return
    end
    socket = TCPSocket.new('localhost', @server_port)
  rescue e
    @error = "Connection failed: #{e}"
  else
    socket.puts string
    socket.close
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

end

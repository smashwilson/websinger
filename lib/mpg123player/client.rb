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
  
  # Status
  
  def player_ok?
    unless File.readable?(@pid_path)
      @error = "Can't read the pid file at #{@pid_path}!"
      return false
    end
    pid = File.open(@pid_path) { |f| f.gets(nil) }.to_i
    Process.kill(0, pid)
  rescue Errno::ESRCH => e
    @error = "The server died!"
    false
  else
    true
  end
  
  def status
    JSON(status_json)
  end
  
  def status_json
    if File.exist?(@status_path)
      File.open(@status_path) { |f| f.gets(nil) }
    else
      Status.stopped.to_json
    end
  end
  
  protected
  
  # Utilities
  
  # Connect to the server, issue a command, and disconnect.
  def command string
    socket = TCPSocket.new('localhost', @server_port)
  rescue e
    @error = "Connection failed: #{e}"
  else
    socket.puts string
    socket.close
  end

end

end

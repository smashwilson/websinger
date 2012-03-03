require 'mpg123player/common'

# Non-ActiveRecord model. Manage status and communications with the mpg123 player process.
class Client
  include Mpg123Player
  include Configurable

  attr_reader :error

  def initialize
    configure
  end

  # Issue a command to the server, synchronously if appropriate.
  def command string, parameter = nil
    raise '#command not implemented'
  end

  # Status

  # Return false and set +error+ if the player is in a bad state.
  def ok?
    true
  end

  # Return a Status object representing the current state of the player, ready for JSON rendering.
  def status
    Status.stopped
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

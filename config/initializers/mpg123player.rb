require 'mpg123player/common'

# Customize the player daemon's configuration options below.  The commented values are the defaults.

# The UNIX user that should run the web application and the player daemon.  This user must have permission to output
# to your audio device (on Ubuntu, by being in the 'audio' group), and must have a sane bash environment for running
# ruby and rake (which can require special care if you're using RVM, for example).
#
# Mpg123Player::Configuration.user = 'websinger'

# The path to the MP3 player's binary.

# Mpg123Player::Configuration.player_path = '/usr/bin/mpg123'

# The home directory for the player daemon's user.  Must be owned by the daemon user.
#
# Mpg123Player::Configuration.base_path = Rails.root.join('tmp')

# A path used to communicate the status of the player daemon's process.
#
# Mpg123Player::Configuration.pid_path = Rails.root.join('tmp', 'pids', 'player.pid')

# This file will be written periodically by the player daemon with a data structure containing information about the
# current track.
#
# Mpg123Player::Configuration.status_path = Rails.root.join('tmp', 'status.yaml')

# A log file containing output from the player daemon.
#
# Mpg123Player::Configuration.log_path = Rails.root.join('log', 'player.log')

# Another log file that traps the $stderr output from the player.  Look here for ALSA errors and so on.
#
# Mpg123Player::Configuration.error_log_path = Rails.root.join('log', 'player.err.log')

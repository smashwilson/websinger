# MP3 Player daemon.  This task must be running in the background for Websinger to
# actually play anything.

namespace :websinger do

  desc 'The MP3 player daemon.  Should be managed by init.'
  task :player => :environment do
    require 'mpg123player/player'

    player = Mpg123Player::Player.new
    player.main_loop
  end

end

# MP3 Player daemon.  This task must be running in the background for Websinger to
# actually play anything.

namespace :websinger do

  desc 'The MP3 player daemon.  Should be managed by init.'
  task :player => :environment do
    require 'mpg123player/server'

    server = Mpg123Player::Server.new
    server.main_loop
  end

end

# MP3 Player daemon.  This task must be running in the background for Websinger to
# actually play anything.

namespace :websinger do

  desc 'The MP3 player daemon.  Should be managed by init.'
  task :player => :environment do
    require 'mpg123player/server'
    
    server = Mpg123Player::Server.new
    POLL_TIME = 1 # seconds (may be fractional)
    
    server.advance do
      e = nil
      e = EnqueuedTrack.top unless server.stay_stopped
      while e.nil? && ! server.shutting_down
        e = EnqueuedTrack.top unless server.stay_stopped
        sleep POLL_TIME
      end
      server.load_track e.track.path, e.track.id unless server.shutting_down
    end
    
    puts 'Starting server...'
    server.start
    server.join
    puts 'Shutting down...'
  end

end

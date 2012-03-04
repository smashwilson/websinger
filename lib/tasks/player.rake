# MP3 Player daemon.  This task must be running in the background for Websinger to
# actually play anything.

namespace :websinger do

  def start_server server_class, log_level_name
    require 'logger'

    log_level = Logger.const_get(log_level_name || :INFO)
    server = server_class.new(1, log_level)
    server.main_loop
  end

  desc 'The MP3 player daemon.  Should be managed by init.'
  task :player, [:log_level] => :environment do |t, args|
    require 'mpg123player/production_server'

    start_server Mpg123Player::ProductionServer, args.log_level
  end

  desc 'Fake MP3 player daemon that advances through tracks, but plays no audio.'
  task :devplayer, [:log_level] => [:environment] do |t, args|
    require 'mpg123player/development_server'

    start_server Mpg123Player::DevelopmentServer, args.log_level
  end

end

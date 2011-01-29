# Generate and install the directory structure and any auxiliary files required to run websinger.

namespace :websinger do
  namespace :install do
    
    desc 'Generate and install the upstart conf file to run the player.'
    task :upstart => :environment do
      # Test for the appropriate filesystem permissions.
      InstallDir = '/etc/init'

      unless File.directory?(InstallDir) && File.writable?(InstallDir)
        $stderr.puts 'Cannot write to the upstart directory:'
        $stderr.puts "  <#{InstallDir}>"
        $stderr.puts
        $stderr.puts 'Please run this task with sudo or rvmsudo.'
        $stderr.puts
        raise 'Insufficient permissions'
      end

      File.open("#{InstallDir}/websinger-player.conf", 'w') do |f|
        f.print <<DONE
# websinger-player

description "Player daemon for the Websinger media center."

start on networking
stop on shutdown

script
  sudo -u www-data bash -l -c "rake -f #{Rails.root}/Rakefile websinger:player"
end script
DONE
      end
    end

    desc 'Install everything.  Run with sudo for best results.'
    task :all => :upstart

  end
end

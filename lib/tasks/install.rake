# Generate and install the directory structure and any auxiliary files required to run websinger.

namespace :websinger do
  namespace :install do

    # Ensure that the websinger user exists and has the appropriate (lack of) permissions.
    task :user => :environment do
      uname = Mpg123Player::Configuration.user
      dir = Mpg123Player::Configuration.base_path

      begin
        Etc.getpwnam uname
        puts "[ok] The application user #{uname} already exists."
      rescue ArgumentError
        puts "[..] The user #{uname} does not exist.  Attempting to create:"

        # Add the user to the audio and rvm groups if they exist.
        groups = ['audio', 'rvm'].select do |group|
          begin
            Etc.getgrnam(group)
            true
          rescue ArgumentError
            puts "[!!] The group #{group} does not exist.  You may need to add an equivalent group manually."
            false
          end
        end
        group_text = groups.empty? ? '' : '-G ' + groups.join(',')

        # -U ==> create a #{uname} group for this user.
        # -G ==> add the user to supplemental groups, if they exist.
        # -d ==> set the user's home directory.
        # -s ==> set the login shell to /bin/false to prevent logins.
        # No -p option ==> no login password.
        system "useradd -U #{group_text} -d #{dir} -s /bin/false #{uname}"
        raise 'Insufficient permissions to create user' unless $? == 0
      end
    end

    # Ensure that the player daemon's status directory exists and is owned correctly.
    task :statusdir => [:user, :environment] do
      require 'fileutils'

      uname = Mpg123Player::Configuration.user
      u = Etc.getpwnam uname

      dir = Mpg123Player::Configuration.base_path

      # Create the daemon directory.
      if File.directory?(dir)
        puts "[ok] Player daemon directory <#{dir}> exists."
      else
        begin
          FileUtils.mkdir_p(dir)
        rescue SystemCallError => e
          puts "[xx] Unable to create player daemon directory"
          raise 'Insufficient permissions'
        end
      end

      # Verify the ownership of the daemon directory.
      if File::Stat.new(dir).uid == u.uid
        puts "[ok] Player daemon directory <#{dir}> is owned by the daemon user."
      else
        puts "[..] Changing the ownership of daemon directory <#{dir}>"
        begin
          FileUtils.chown_R u.uid, u.gid, dir, :verbose => true
        rescue
          puts "[xx] Unable to change ownership."
          raise
        end
      end

      # Verify the daemon user's .bashrc and .bash_profile files.
      if File.exist? "#{dir}/.bashrc"
        puts "[ok] Daemon user's .bashrc exists."
      else
        puts "[..] Creating a .bashrc that will load a systemwide RVM installation."
        File.open("#{dir}/.bashrc", 'w') do |f|
          f.print <<BASHRC
[[ -s "/usr/local/lib/rvm" ]] && source "/usr/local/lib/rvm"  # This loads RVM into a shell session.
BASHRC
        end
        puts "[ok] .bashrc file created."
      end

      if File.exist? "#{dir}/.bash_profile"
        puts "[ok] Daemon user's .bash_profile exists."
      else
        puts "[..] Creating a .bash_profile that loads .bashrc."
        File.open("#{dir}/.bash_profile", 'w') do |f|
          f.print <<BASHPROFILE
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi
BASHPROFILE
        end
        puts "[ok] .bash_profile file created."
      end
    end

    # Ensure that the application directory is owned by the correct user.
    task :ownership => [:user, :environment] do
      require 'fileutils'

      uname = Mpg123Player::Configuration.user
      u = Etc.getpwnam uname

      # According to Phusion Passenger documentation, this is the file used
      # to establish the user the application is launched as.
      stat = File::Stat.new(Rails.root.join 'config', 'environment.rb')
      if stat.uid != u.uid
        puts "[..] Changing application ownership to #{uname}:#{uname}."
        begin
          FileUtils.chown_R u.uid, u.gid, Rails.root, :verbose => true
        rescue
          puts "[xx] Unable to change application ownership."
          raise
        end
      else
        puts "[ok] config/environment.rb has the correct owner."
      end
    end
    
    # Generate and install the upstart conf file to run the player.
    task :upstart => [:user, :statusdir, :ownership, :environment] do
      InstallDir = '/etc/init'
      uname = Mpg123Player::Configuration.user

      # Test for the appropriate filesystem permissions.
      unless File.directory?(InstallDir) && File.writable?(InstallDir)
        puts "[xx] Cannot write to the upstart directory: <#{InstallDir}>"
        raise 'Insufficient permissions'
      end

      bash_path = `which bash`.chomp
      rake_path = $0

      File.open("#{InstallDir}/websinger-player.conf", 'w') do |f|
        f.print <<DONE
# websinger-player

description "Player daemon for the Websinger media center."

start on networking
stop on shutdown

console output

exec /bin/su -l -c "RAILS_ENV=#{Rails.env} #{rake_path} -f #{Rails.root}/Rakefile websinger:player" #{uname}
DONE
      end
      puts "[ok] wrote #{InstallDir}/websinger-player.conf"
    end

    desc 'Install everything websinger-related [run with sudo, if you trust me ;-)]'
    task :all => :upstart

  end
end

module Websinger
  def self.load_settings
    path = Rails.root.join('config', 'websinger.yml')
    path = Rails.root.join('config', 'websinger.yml.example') unless path.exist?
    hash = YAML.load_file(path)
    OpenStruct.new hash
  end

  Settings = load_settings

  # Apply defaults
  Settings.player_path ||= "/usr/bin/mpg123"
  Settings.status_path ||= "tmp/status.yml"
  Settings.pid_path ||= "tmp/player.pid"
  Settings.log_out_path ||= "log/player.out.log"
  Settings.log_err_path ||= "log/player.err.log"
  Settings.command_poll ||= 0.1
  Settings.command_timeout ||= 5
end

# A logger that can have its level elevated for specific actions, such as the player and playlist polling
# requests.

# Courtesy of: http://dennisreimann.de/blog/silencing-the-rails-log-on-a-per-action-basis/

class SelectiveLogger < Rails::Rack::Logger
  include ActiveSupport::BufferedLogger::Severity

  def initialize app, opts = {}
    @app = app
    @opts = opts
    @opts[:silenced] ||= []
  end

  def call env
    if env['X-SILENCE-LOGGER'] || (@opts[:silenced].include?(env['PATH_INFO']) && env['REQUEST_METHOD'] == 'GET')
      Rails.logger.silence(WARN) { @app.call(env) }
    else
      super(env)
    end
  end
end

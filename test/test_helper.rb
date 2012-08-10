ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'mpg123player/common'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  class TestClient < Client
    def initialize
      super
      @status = Mpg123Player::Status.stopped
      @asynchronous = true
    end

    def ok?
      true
    end
  end

  def music_path *parts
    Rails.root.join('test', 'fixtures', 'music', *parts).to_s
  end
end

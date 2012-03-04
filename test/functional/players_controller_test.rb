require 'test_helper'
require 'active_support/json'

require 'mpg123player/common'

class PlayersControllerTest < ActionController::TestCase

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

  test "issue commands through the client" do
    @controller.client = TestClient.new

    post :update, { :command => 'volume', :parameter => '70' }

    assert_response :success
    assert @response.body.blank?

    @c = PlayerCommand.flush_queue[0]
    assert_equal 'volume', @c.action
    assert_equal '70', @c.parameter
  end

end

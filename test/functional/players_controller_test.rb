require 'test_helper'
require 'active_support/json'

class PlayersControllerTest < ActionController::TestCase

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

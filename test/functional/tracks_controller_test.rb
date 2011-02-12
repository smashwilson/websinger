require 'test_helper'

class TracksControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show_album" do
    get :show_album
    assert_response :success
  end

end

require 'test_helper'

class PlaylistsControllerTest < ActionController::TestCase

  test "render current client status" do
    @client = TestClient.new
    @client.status.track_id = 1
    @client.status.length = 60
    @client.status.playback_state = :playing

    @controller.client = @client

    get :show

    assert_response :success
    assert_not_nil assigns(:status)

    # The initial status display should be populated with the current track and control status.
    assert_select '.player' do
      # Album art
      assert_select 'img.album-art' do |imgs|
        assert_equal 1, imgs.size
        assert_equal "/tracks/1/album-art", imgs[0]['src']
      end

      # Control enablement
      assert_select 'a.disable#command_restart', 0
      assert_select 'a.disable#command_pause', 0
      assert_select 'a.disable#command_play', 1
      assert_select 'a.disable#command_skip', 0
      assert_select '.progress-text', '0:00 / 1:00'

      # Textual track information
      assert_select '.title', 'Song 1'
      assert_select '.artist', 'Artist 0'
      assert_select '.album', 'Album 0'
    end
  end

  test "render status when stopped" do
    @client = TestClient.new
    @controller.client = @client

    get :show

    assert_response :success
    assert_not_nil assigns(:status)

    assert_select '.player' do
      # Empty album art
      assert_select 'img.album-art' do |imgs|
        assert_equal 1, imgs.size
        assert_equal "/tracks/empty/album-art", imgs[0]['src']
      end

      # Control enablement
      assert_select 'a.disable#command_restart', 0
      assert_select 'a.disable#command_pause', 1
      assert_select 'a.disable#command_play', 0
      assert_select 'a.disable#command_skip', 0
      assert_select '.progress-text', ''
    end
  end

end

require 'test_helper'

class TracksControllerTest < ActionController::TestCase

  test "should access album art" do
    t = Track.new
    t.update_from_path(music_path 'track-with-album-art', 'folder-album-art.mp3')
    t.save!

    get :album_art, { :id => t.id }
    assert_response :success
    assert_equal 'image/png', @response.header['Content-Type']
  end

  test "should provide placeholder album art" do
    t = Track.new
    t.update_from_path(music_path 'full-tags.mp3')
    t.save!

    get :album_art, { :id => t.id }
    assert_response :success
    assert_equal 'image/png', @response.header['Content-Type']
    assert_equal 'true', @response.header['x-placeholder-art']
  end

  test "explicit request for placeholder album art" do
    get :album_art, { :id => 'placeholder' }

    assert_response :redirect
    assert @response.header['Location'].ends_with?('missing-album.png')
  end

  test "request for empty album art" do
    get :album_art, { :id => 'empty' }

    assert_response :redirect
    assert @response.header['Location'].ends_with?('empty-album.png')
  end

end

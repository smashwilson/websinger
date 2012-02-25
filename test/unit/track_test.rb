require 'test_helper'

class TrackTest < ActiveSupport::TestCase
  test 'unique by mp3 path' do
    Track.create!(:title => 'foo', :path => '/some/path.mp3')
    assert !Track.create(:title => 'blarg', :path => '/some/path.mp3').valid?
  end

  test 'unique by title within same artist and album' do
    Track.create!(:title => 'foo', :artist => 'same', :album => 'same')

    assert Track.create(:title => 'foo', :artist => 'same', :album => 'different').valid?
    assert Track.create(:title => 'foo', :artist => 'different', :album => 'same').valid?
    assert Track.create(:title => 'foo', :artist => 'different', :album => 'different').valid?
    assert !Track.create(:title => 'foo', :artist => 'same', :album => 'same').valid?
  end

  test 'read mp3 info from track' do
    t = Track.new
    t.update_from_path 'test/fixtures/music/full-tags.mp3'

    assert_equal 'test/fixtures/music/full-tags.mp3', t.path
    assert_equal 'track title', t.title
    assert_equal 'artist', t.artist
    assert_equal 'artist', t.artist_slug
    assert_equal 'album', t.album
    assert_equal 'album', t.album_slug
    assert_equal 4, t.track_number
    assert_equal 16, t.disc_number

    assert t.save
  end

  test 'search on title, artist and album' do
    Track.create!(:title => 'xx term yy', :artist => 'no', :album => 'no')
    Track.create!(:title => 'yes0', :artist => 'aa term bb', :album => 'no')
    Track.create!(:title => 'yes1', :artist => 'no', :album => 'qqq term zz')
    Track.create!(:title => 'no', :artist => 'no', :album => 'no')

    results = Track.matching('term').map(&:title).sort
    assert_equal [ 'xx term yy', 'yes0', 'yes1'], results
  end

  test 'retrieve a random sampling' do
    1.upto(50) do |i|
      Track.create!(:title => "Track #{i}")
    end

    sample = Track.sample
    assert_equal Track.per_page, sample.size
  end

  test 'fetch by album' do
    #
  end

end

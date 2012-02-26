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
    sample = Track.sample
    assert_equal Track.per_page, sample.size
  end

  test 'fetch by album' do
    Track.all.each { |t| t.reslug && t.save! }

    # A simple album
    album0 = Track.in_album('artist-0', 'album-0')
    assert_equal (1..9).to_a, album0.map(&:track_number)
    assert_equal 'Song 1', album0[0].title

    # An album with disc numbers. Even tracks are on disc 0, odd ones on disc 1.
    album4 = Track.in_album('artist-2', 'album-4')
    assert_equal [0, 2, 4, 6, 8, 1, 3, 5, 7, 9], album4.map(&:track_number)
  end

end

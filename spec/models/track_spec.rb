require 'spec_helper'

describe Track do
  it "is unique by path" do
    original = create :track
    dup = build :track, path: original.path
    dup.save.should be_false
    dup.should_not be_valid
  end

  it "has many enqueued tracks"

  it "represents itself as a string" do
    t = create :track, artist: 'me', title: 'a song'
    t.to_s.should == "me - a song"
  end

  it "finds its own album art"

  it "generates artist and album slugs" do
    t = create :track, artist: 'Some Crazy Artist &&&', album: 'Special + characters'
    t.artist_slug.should == 'some-crazy-artist-and-and-and'
    t.album_slug.should == 'special-plus-characters'
  end

  it "reads metadata from an actual mp3 file"
  it "ignores invalid UTF-8 characters in various fields"

  it "does a substring search on artist, album and title" do
    yes = []
    create :track
    yes << create(:track, artist: 'Artist Yes')
    yes << create(:track, album: 'Rise of the Yes')
    yes << create(:track, title: 'A Track Yes Title')

    Track.matching('yes').should =~ yes
  end

  it "shows all tracks within an album" do
    yes = []
    create :track
    yes << create(:track, album: 'An Album', artist: 'An Artist')
    yes << create(:track, album: 'An Album', artist: 'An Artist')

    Track.in_album('an-artist', 'an-album').should =~ yes
  end

  it "performs a random sampling"
end
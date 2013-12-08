require 'spec_helper'

describe Track do
  it "is unique by path"

  it "has many enqueued tracks"
  it "represents itself as a string"
  it "finds its own album art"
  it "generates artist and album slugs"
  it "reads metadata from an actual mp3 file"
  it "ignores invalid UTF-8 characters in various fields"

  it "does a substring search on artist, album and title"
  it "shows all tracks within an album"
  it "performs a random sampling"
end
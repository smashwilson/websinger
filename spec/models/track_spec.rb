require 'spec_helper'

describe Track do
  it "has many enqueued tracks"
  it "represents itself as a string"
  it "finds its own album art"
  it "generates artist and album slugs"
  it "updates empty metadata from an actual track"
  it "ignores invalid UTF-8 characters in various fields"

  it "does a substring search on artist, album and title"
  it "shows all tracks within an album"
  it "performs a random sampling"
end
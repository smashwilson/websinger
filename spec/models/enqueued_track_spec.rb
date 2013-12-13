require 'spec_helper'

describe EnqueuedTrack do
  it "must be associated with a track"

  it "returns all enqueued tracks in position order with #playlist"

  describe "#enqueue" do
    it "enqueues a track at the end of the playlist by default"
    it "enqueues a track at the start of the playlist with :top"
  end

  describe "#enqueue_all" do
    it "enqueues multiple tracks at the end of the playlist"
    it "enqueues multiple tracks at the start of the playlist"
  end

  describe "#top" do
    context "with no tracks enqueued" do
      it "returns nil if no tracks are enqueued"
    end

    context "with tracks enqueued" do
      it "returns the track with the lowest position"
      it "deletes the track"
    end
  end
end
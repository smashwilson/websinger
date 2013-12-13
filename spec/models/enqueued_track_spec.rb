require 'spec_helper'

describe EnqueuedTrack do
  let(:e1) { create :enqueued_track, position: 1 }
  let(:e2) { create :enqueued_track, position: 2 }
  let(:e3) { create :enqueued_track, position: 3 }
  let(:playlist) { [e1, e2, e3] }

  it "must be associated with a track" do
    build(:enqueued_track, track: nil).should_not be_valid
  end

  it "returns all enqueued tracks in position order with #playlist" do
    playlist
    EnqueuedTrack.playlist.should == playlist
  end

  describe "#enqueue" do
    let(:track) { create :track }

    it "enqueues a track at the end of the playlist by default" do
      e = EnqueuedTrack.enqueue track
      EnqueuedTrack.playlist.last.should == e
    end

    it "enqueues a track at the start of the playlist with :top" do
      e = EnqueuedTrack.enqueue track, :top
      EnqueuedTrack.playlist.first.should == e
    end
  end

  describe "#enqueue_all" do
    let(:t1) { create :track }
    let(:t2) { create :track }
    let(:both) { [t1, t2] }

    before { playlist }

    it "enqueues multiple tracks at the end of the playlist" do
      es = EnqueuedTrack.enqueue_all both
      EnqueuedTrack.playlist.should == playlist + es
    end

    it "enqueues multiple tracks at the start of the playlist" do
      es = EnqueuedTrack.enqueue_all both, :top
      EnqueuedTrack.playlist.should == es + playlist
    end
  end

  describe "#top" do
    context "with no tracks enqueued" do
      it "returns nil if no tracks are enqueued" do
        EnqueuedTrack.top.should be_nil
      end
    end

    context "with tracks enqueued" do
      before { playlist }

      it "returns the track with the lowest position" do
        EnqueuedTrack.top.should == e1
      end

      it "deletes the track from the playlist" do
        EnqueuedTrack.top
        EnqueuedTrack.playlist.should_not include(e1)
      end
    end
  end
end

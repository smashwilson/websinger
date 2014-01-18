require 'spec_helper'

describe Status do
  let(:track_data) do
    [:artist, :album, :title, :length]
  end
  let(:track) { create :track }
  let(:status) { Status.new }

  context "initial state" do
    it "should be ready to play" do
      status.playback_state.should == :playing
    end

    it "should be at zero seconds" do
      status.seconds.should == 0
    end

    it "starts at full volume" do
      status.volume.should == 100
    end
  end

  it "inherits track data" do
    status.seconds = 10

    status.on_track track
    status.title.should == track.title
    status.artist.should == track.artist
    status.album.should == track.album
    status.length.should == track.length
    status.track_id.should == track.id
    status.seconds.should == 0
  end

  it "clears out old track data" do
    status.on_track track
    status.clear

    status.title.should be_nil
    status.artist.should be_nil
    status.album.should be_nil
    status.length.should == 1
    status.track_id.should be_nil
    status.seconds.should == 0
  end

  describe "#is_close_to" do
    let(:base) { Status.new.tap { |s| s.on_track track } }
    let(:same_track) { Status.new.tap { |s| s.on_track track } }
    let(:other_track) { Status.new.tap { |s| s.on_track(create :track) } }

    it "is never close to nil" do
      base.should_not be_close_to(nil)
    end

    it "compares track data" do
      base.should be_close_to(same_track)
    end

    it "compares volume" do
      base.volume = 10
      same_track.volume = 90

      base.should_not be_close_to(same_track)
    end

    it "accepts statuses within one second" do
      base.seconds = 24.2
      same_track.seconds = 23.8

      base.should be_close_to(same_track)
    end

    it "rejects statuses different by more than one second" do
      base.seconds = 23.2
      same_track.seconds = 24.3

      base.should_not be_close_to(same_track)
    end
  end

  describe "#progress_text" do
    context "with a track" do
      before { status.on_track track }

      it "formats the elapsed and total track times" do
        status.seconds = 11
        status.length = 12
        status.progress_text.should == "0:11 / 0:12"
      end

      it "calculates minutes" do
        status.seconds = 70
        status.length = 255

        status.progress_text.should == "1:10 / 4:15"
      end

      it "includes a trailing zero on the seconds" do
        status.seconds = 5
        status.length = 124

        status.progress_text.should == "0:05 / 2:04"
      end
    end

    it "returns blank text without a track" do
      status.progress_text.should == ""
    end
  end

  it "round-trip itself as a hash" do
    status.on_track track
    reconstructed = Status.from(status.to_h)
    reconstructed.should be_close_to(status)
  end

  it "creates a stopped state" do
    s = Status.stopped
    s.playback_state.should == :stopped
    s.seconds.should == 0
  end
end

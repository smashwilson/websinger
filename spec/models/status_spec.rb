require 'spec_helper'

describe Status do
  let(:track_data) do
    [:artist, :album, :title, :length]
  end
  let(:track) { create :track }

  context "initial state" do
    let(:status) { Status.new }

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

  it "inherits track data"
  it "clears out old track data"

  describe "#is_close_to" do
    it "is never close to nil"
    it "compares track data"
    it "compares volume"
    it "accepts statuses within one second"
    it "rejects statuses different by more than one second"
  end

  describe "#progress_text" do
    it "generates progress text"
    it "returns blank text without a track"
  end

  it "encodes itself as a hash"

  it "reconstructs itself from a hash"

  it "creates a stopped state"
end

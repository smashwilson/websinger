class TrackController < ApplicationController

  def index
    @tracks = Track.all
  end

  def show_album
  end

end

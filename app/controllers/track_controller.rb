class TrackController < ApplicationController

  def index
    @tracks = Track.matching(params[:query])
  end

  def show_album
  end

end

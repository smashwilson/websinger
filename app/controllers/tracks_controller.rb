class TracksController < ApplicationController

  def index
    @tracks = Track.matching(params[:query]).paginate(:page => params[:page], :per_page => 20)
  end

  def show_album
  end

end

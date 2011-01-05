class PlaylistsController < ApplicationController

  def show
    @playlist = EnqueuedTrack.playlist
  end

  def update
  end

  def destroy
  end

  def sort
  end

end

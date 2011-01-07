class PlaylistsController < ApplicationController

  def show
    @playlist = EnqueuedTrack.playlist
  end

  def update
  end

  def enqueue
    track = Track.find params[:id]

    if track.nil?
      render :status => 404, :text => "Track (#{params[:id]}) not found"
      return
    end

    e = EnqueuedTrack.enqueuement_of track
    unless e.valid?
      render :status => 500, :text => "Unable to enqueue track: #{e.errors.full_messages.join ' '}"
    end

    render :text => "#{track} has been added to the playlist at position #{e.position}."
  end

  def dequeue
  end

end

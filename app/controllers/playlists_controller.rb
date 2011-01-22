class PlaylistsController < ApplicationController

  def show
    @playlist = EnqueuedTrack.playlist

    render :partial => 'playlist', :object => @playlist if request.xhr?
  end

  # Reorder the tracks within the playlist.
  def update
    @playlist = EnqueuedTrack.playlist
    
    EnqueuedTrack.transaction do
      @playlist.each do |enqueued|
        enqueued.position = params[:enqueued_track].index(enqueued.id.to_s) + 1
        enqueued.save
      end
    end
    
    render :nothing => true
  end

  # Enqueue a new track by track id.
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

  # Remove an existing EnqueuedTrack by *queue* id.
  def dequeue
    e = EnqueuedTrack.find params[:id]
    if e.nil?
      render :status => 404, :text => "Track (#{params[:id]}) not found"
      return
    end
    
    e.delete
    
    render :text => "#{e.track} has been removed from the playlist."
  end

end

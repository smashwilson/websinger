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

  # Enqueue a new track.
  def enqueue
    track = Track.find params[:id]
    e = EnqueuedTrack.enqueue track
    
    unless e.valid?
      render :status => 500, :text => "Unable to enqueue track: #{e.errors.full_messages.join ' '}", :content_type => 'text/plain'
      return
    end

    render :text => "#{track} has been added to the playlist.", :content_type => 'text/plain'
  end
  
  def enqueue_all
    tracks = Track.find params[:ids]
    es = EnqueuedTrack.enqueue_all tracks
    
    unless es.all? { |e| e.valid? }
      summary = es.inject('') { |e,text| "#{text} #{e.errors.full_messages.join ' '}" }
      render :status => 500, :text => "Unable to enqueue tracks: #{summary}", :content_type => 'text/plain'
    end
    
    render :text => "#{tracks.size} tracks have been added to the playlist.", :content_type => 'text/plain'
  end

  # Remove an existing EnqueuedTrack by *queue* id.
  def dequeue
    e = EnqueuedTrack.find params[:id]
    if e.nil?
      render :status => 404, :text => "Track (#{params[:id]}) not found", :content_type => 'text/plain'
      return
    end
    
    e.delete
    
    render :text => "#{e.track} has been removed from the playlist.", :content_type => 'text/plain'
  end

  # Clear the entire playlist.
  def clear
    EnqueuedTrack.delete_all

    render :text => "Playlist cleared.", :content_type => 'text/plain'
  end

end

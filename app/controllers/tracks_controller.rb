class TracksController < ApplicationController

  def index
  end

  def results
    @tracks = Track.matching(params[:query])
    response.headers['x-query'] = params[:query]
    render :layout => !request.xhr?
  end

  def sample
    @tracks = Track.sample
    render :layout => !request.xhr?
  end

  def autocomplete
    matches = Track.matching(params[:term]).limit(20).map do |t|
      { 'id' => t.id, 'label' => t.to_s, 'value' => t.to_s }
    end
    render :json => matches
  end

  def show_album
    @tracks = Track.in_album(params[:artist_slug], params[:album_slug])
    if @tracks.empty?
      render :status => 404, :text => 'Unknown album.', :content_type => 'text/plain'
      return
    end

    @track = @tracks[0]
    @track_ids = @tracks.map { |t| t.id }
  end

  def album_art
    if params[:id] == 'placeholder'
      art = AlbumArt.default
    else
      @track = Track.find(params[:id])
      art = @track.album_art
    end

    response.headers['x-placeholder-art'] = 'true' if art.default?
    if art && art.ok?
      send_data art.image, :type => art.mime_type, :disposition => 'inline'
    else
      render :text => 'Album art corrupted', :status => 500, :content_type => 'text/plain'
    end
  end

end

class TracksController < ApplicationController

  def index
  end

  def results
    @tracks = Track.matching(params[:query]).paginate(:page => params[:page], :per_page => Track.per_page)
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
    @track = Track.find(params[:id])
    art = @track.album_art

    # TODO use a default album image

    if art && art.ok?
      send_data art.image, :type => art.mime_type, :disposition => 'inline'
    else
      render :text => 'Missing album art', :status => 404, :content_type => 'text/plain'
    end
  end

end

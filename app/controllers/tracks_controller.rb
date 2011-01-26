class TracksController < ApplicationController

  def index
    @tracks = Track.matching(params[:query]).paginate(:page => params[:page], :per_page => 20)
  end
  
  def autocomplete
    matches = Track.matching(params[:term]).limit(20).map do |t|
      { 'id' => t.id, 'label' => t.to_s, 'value' => t.to_s }
    end
    render :json => matches
  end

  def show_album
    @tracks = Track.in_album(params[:artist], params[:album])
  end

  def album_art
    @track = Track.find(params[:id])
    art = @track.album_art
    send_data art.image, :type => art.mime_type, :disposition => 'inline'
  end

end

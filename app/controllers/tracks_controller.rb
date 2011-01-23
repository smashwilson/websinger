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
  end

end

require 'mpg123player/common'

class PlayersController < ApplicationController
  before_filter :create_player_client

  def show
    render :json => @status
  end

  def update
    @player.command(params[:command], params[:parameter])
    if @player.error
      render :status => 500, :text => @player.error, :content_type => 'text/plain'
    else
      render :nothing => true
    end
  end

  private

  def create_player_client
    @player = Client.new
    @player.ok?

    @status = @player.status
    if @status.track_id
      @track = Track.where(:id => @status.track_id).first
    end
  end

end

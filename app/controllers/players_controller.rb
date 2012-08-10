require 'mpg123player/common'

class PlayersController < ApplicationController

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

end

class PlayersController < ApplicationController

  def show
    render :json => @status
  end

  def update
    @player.command(params[:command])
    if @player.error
      render :status => 500, :text => @player.error
    else
      render :nothing => true
    end
  end

end

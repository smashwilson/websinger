require 'mpg123player/client'

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :create_player_client
  
  private

  def create_player_client
    @player = Mpg123Player::Client.new
    @player.ok?
    @status = @player.status
    if @status.track_id
      @current_track = Track.find(@status.track_id)
      @status.track_length = @current_track.length
    end
  end
  
end

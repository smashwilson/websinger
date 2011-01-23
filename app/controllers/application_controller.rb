require 'mpg123player/client'

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :create_player_client
  
  private

  def create_player_client
    @player = Mpg123Player::Client.new
    @player.ok?
    
    @status = @player.status
    @status.track = Track.find(@status.track_id) if @status.track_id
  end
  
end

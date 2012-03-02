class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :create_player_client

  private

  def create_player_client
    @player = Player.new
    @player.ok?

    @status = @player.status
    if @status.track_id
      @status.track = Track.where(:id => @status.track_id).first
    end
  end

end

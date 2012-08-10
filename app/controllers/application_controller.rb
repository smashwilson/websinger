require 'mpg123player/common'
require 'track'
require 'empty_track'

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :create_player_client
  attr_accessor :client

  protected

  def create_player_client
    @player = @client || Client.new
    @player.ok?

    @status = @player.status
    if @status.track_id
      @track = Track.find(@status.track_id)
    else
      @track = EmptyTrack.new
    end
  end

end

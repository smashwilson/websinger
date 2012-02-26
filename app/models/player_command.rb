require 'mpg123player/common'

class PlayerCommand < ActiveRecord::Base
  validates :action, :inclusion => { :in => Mpg123Player::Commands }

  def self.flush_queue
    transaction { order(:created_at).map(&:destroy) }
  end

end

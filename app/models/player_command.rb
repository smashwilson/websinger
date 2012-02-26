class PlayerCommand < ActiveRecord::Base
  validates :action, :inclusion => { :in => %w(play pause restart skip volume) }

  def self.flush_queue
    transaction { order(:created_at).map(&:destroy) }
  end

end

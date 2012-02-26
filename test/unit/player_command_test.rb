require 'test_helper'

class PlayerCommandTest < ActiveSupport::TestCase
  test "ensure valid actions" do
    assert PlayerCommand.create(:action => 'play').valid?
    assert PlayerCommand.create(:action => 'pause').valid?
    assert !PlayerCommand.create(:action => 'huuurf').valid?
  end

  test "clear command queue" do
    c1 = PlayerCommand.create!(:action => 'play')
    c2 = PlayerCommand.create!(:action => 'volume', :parameter => '90')
    c3 = PlayerCommand.create!(:action => 'pause')

    queue = PlayerCommand.flush_queue
    assert PlayerCommand.all.empty?
    assert_equal ['play', 'volume', 'pause'], queue.map(&:action)
  end
end

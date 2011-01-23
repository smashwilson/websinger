module PlayersHelper

  def command_link command, enabled = true, args = {}
    args[:method] = 'PUT'
    args[:remote] = true
    args[:id] = "command_#{command}"
    args[:class] = 'disable' unless enabled
    link_to command, player_path(:command => command), args
  end
  
  def percent_complete
    @current_track ? @current_track.percent_complete(@status.seconds) : 0
  end
  
  def time_s
    @current_track ? "#{@status.seconds_s} / #{@current_track.length_s}" : ''
  end

end

module PlayersHelper

  def command_link command, enabled = true, args = {}
    args[:method] = 'PUT'
    args[:remote] = true
    args[:id] = "command_#{command}"
    args[:class] = 'disable' unless enabled
    link_to command, player_path(:command => command), args
  end

end

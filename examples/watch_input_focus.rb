require 'vigilem/x11/terminal_window_utils'
require 'vigilem/x11/input_system_handler'

@term_window_id = Vigilem::X11::TerminalWindowUtils.window_id

isys = Vigilem::X11::InputSystemHandler.new(@term_window_id, ENV['DISPLAY'])


def has_focus?(display, win_id)
  with_focus = Vigilem::X11.get_input_focus(display, win_id)[1]
  with_focus == win_id or
  @term_window_id == Vigilem::X11.query_tree(display, with_focus)[:parent_return]
end

puts 'listening for focus...'

while true
  
  focus_window_id = isys.get_input_focus.first
  
  has_focus = has_focus?(isys.display, @term_window_id)
  
  if (not @had_focus) and has_focus
    puts "gained_focus" 
    @had_focus = true
  elsif @had_focus and not has_focus
    puts "lost_focus"
    @had_focus = false
  end
  
  sleep 1
end

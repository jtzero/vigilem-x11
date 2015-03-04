require 'vigilem/x11/terminal_window_utils'
require 'vigilem/x11/input_system_handler'

window_xid = Vigilem::X11::TerminalWindowUtils.window_id

isys = Vigilem::X11::InputSystemHandler.new(window_xid, ENV['DISPLAY'],  Xlib::KeyPressMask | Xlib::FocusChangeMask)

def got_focus?
  @got_focus
end

def got_focus_or_nil?
  [got_focus?, true].compact.first
end


def not_focus_or_nil?
  not [got_focus?, false].compact.first
end

#0 NotifyNormal,       0 NotifyAncestor
#1 NotifyGrab,         1 NotifyVirtual
#2 NotifyUngrab,       2 NotifyInferior
#3 NotifyWhileGrabbed, 3 NotifyNonlinear
#                      4 NotifyNonlinearVirtual

# 1,1 and 3,3
# 0,4 and 0,3
# 1,1 and 2,1

def gained_focus?(focus_event)
  comb = [focus_event[:mode], focus_event[:detail]]
  not_focus_or_nil? and focus_event[:type] == Xlib::FocusIn and
  (comb == [Xlib::NotifyWhileGrabbed, Xlib::NotifyNonlinear] or
  comb == [Xlib::NotifyNormal, Xlib::NotifyNonlinear] or
  comb == [Xlib::NotifyUngrab, Xlib::NotifyVirtual])
end

def lost_focus?(focus_event)
  comb = [focus_event[:mode], focus_event[:detail]]
  got_focus_or_nil? and focus_event[:type] == Xlib::FocusOut and
  (comb == [Xlib::NotifyGrab, Xlib::NotifyVirtual] or
   comb == [Xlib::NotifyNormal, Vigilem::X11::NotifyNonlinearVirtual])
end

puts 'listening for focus...'
arg ||= []
while true
  arg = isys.read_many_nonblock
  until arg.empty?
    event = arg.shift[:xfocus]
      
    vals = if ARGV[0] == 'info'
      "=>#{event.class.members.map {|m| "#{m}=#{event[m]}" }.join('|')}"
    end
    if gained_focus?(event)
      puts "gained_focus#{vals}" 
      @got_focus = true
    elsif lost_focus?(event)
      puts "lost_focus#{vals}"
      @got_focus = false
    end
    
  end
  
end

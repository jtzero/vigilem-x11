require 'vigilem/x11'

require 'vigilem/core/input_system_handler'

require 'vigilem/x11/constants'

require 'vigilem/x11/display'

require 'vigilem/x11/event_queue'

module Vigilem
module X11
  # 
  # 
  class InputSystemHandler
    include Core::InputSystemHandler
    
    attr_reader :window_xid, :demultiplexer
    
    # 
    # @param  [Integer] win_xid
    # @param  [String || Display || ::FFI::Pointer] display_pointer_or_name
    # @param  [Integer] event_mask
    def initialize(win_xid, display_obj_pointer_or_name, event_mask=nil)
      
      initialize_input_system_handler
      
      display = Display.open(display_obj_pointer_or_name)
      
      @demultiplexer = Core::Demultiplexer.acquire(EventQueue.new(display), [[self.buffer, {:func => :concat}]]) do |dem| 
        dem.input.respond.fileno == display.fileno
      end
      
      @window_xid = win_xid
      
      self.select_input(event_mask) if event_mask
      
    end
    
    include Core::Eventable
    
    # 
    # @param  [Fixnum] num
    # @return [Array]
    def read_many_nonblock(num=1)
      synchronize {
        demultiplexer.demux(num)
        buffer.slice!(0, num)
      }
    end
    
    # @todo   handle `X Error of failed request:  BadWindow (invalid Window parameter)'
    # @param  [Fixnum] 
    # @return [Fixnum] 
    def select_input(event_mask)
      Xlib.XSelectInput(demultiplexer.input.display, window_xid, event_mask)
    end
    
    def_delegators :'demultiplexer.input', :pending, :display
    
    # @see    http://www.unix.com/man-page/All/3x/XGetInputFocus/
    # @return [Array<Integer, Fixnum>] [xwindow_id, revert_to_return]
    def get_input_focus
      X11.get_input_focus(display, window_xid, 0)[1..-1]
    end
    
    # @see    ::query_tree
    # @return [Hash] 
    def query_tree(opts={})
      X11.query_tree(display, window_xid, opts)
    end
    
  end
end
end

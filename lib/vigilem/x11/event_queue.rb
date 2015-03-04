require 'xlib'

require 'vigilem/support/obj_space'

require 'vigilem/core/buffer'

require 'vigilem/core/eventable'

require 'vigilem/x11/display'

module Vigilem
module X11
  # 
  # 
  class EventQueue
    
    include Core::Buffer
    
    attr_reader :display
    
    extend Support::ObjSpace
    
    class << self
      # 
      # @param [String || Display || ::FFI::Pointer] 
      #          display_pointer_or_name
      def new(display_obj_pointer_or_name)
        ret = obj_register(super(display_obj_pointer_or_name))
        same_display_check!
        ret
      end
      
      # 
      # finds an existing EventQueue with the given display or
      # returns a new one based on the items passed in
      # @param  [Display || FFI::Pointer || String] 
      #           display_obj_pointer_or_name
      # @return [EventQueue]
      def acquire(display_obj_pointer_or_name)
        dip = Display.wrap(display_obj_pointer_or_name)
        eventq = all.find {|evq| evq.fileno == dip.fileno }
        
        eventq || new(dip)
      end
      
      # 
      # @return [Array]
      def same_display_check
        all.group_by {|ev| ev.display.fileno }.select {|k, v| v.size > 1 }
      end
      
      # 
      # @param  [StandardError] err_type, defaults to ArgumentError
      # @raise  "EventQueues should not have the same display `#{array of event queues with same display}'"
      # @return [NilClass]
      def same_display_check!(err_type=ArgumentError)
        unless (dups = same_display_check).empty?
          raise err_type, "EventQueues should not have the same display `#{dups}'"
        end
      end
      
    end
    
    # 
    # @param  [String || Display || ::FFI::Pointer] 
    #           display_pointer_or_name
    def initialize(display_obj_pointer_or_name)
      @display = Display.wrap(display_obj_pointer_or_name)
    end
    
    # the XPending and items pulled from the queue that
    # haven't propagated
    # @return [Fixnum]
    def pending
      pending! + _internal_buffer.size
    end
    
    # only the number of events returned by XPending
    # @return [Fixnum]
    def pending!
      Xlib.XPending(display!)
    end
    
    # 
    # @return [Xlib::XEvent]
    def next_event
      x_event = Xlib::XEvent.new
      Xlib.XNextEvent(display!, x_event)
      x_event
    end
    
    # 
    # @return [Fixnum]
    def fileno
      @fileno ||= display.fileno
    end
    
    # 
    # @raise  [ArgumentError]
    # @return 
    def display!
      # a way to validate the pointer to prevent segfault?
      if display.is_a?(::FFI::Pointer) or display.respond_to?(:to_ptr)
        display
      else
        raise ArgumentError, "Display is a `#{display.inspect}'" + 
                            "and doesn't respond to :to_ptr"
      end
    end
    
    # 
    # @param  [Integer || Range] start_idx_range
    # @param  [Integer] len
    # @return [Array]
    def slice!(start_idx_range, len=nil)
      # this isn;t the most efficient way, but is the
      # most straight forward
      pending!.times.map do
        next_event
      end.compact.slice!(start_idx_range, *len)
    end
    
    # 
    # @raise  [NotImplemented]
    def concat(*args)
      raise NotImplementedError
    end
    
    # 
    # @raise  [NotImplemented]
    def peek
      raise NotImplementedError
      # @todo
      #if _internal_buffer.size > 0
      #  _internal_buffer[0]
      #else
      #  if pending! > 0
      #    next_event
      #  end
      #end
    end
    
   private
    # 
    # @return [Array]
    def _internal_buffer
      @internal_buffer ||= []
    end
    
  end
end
end

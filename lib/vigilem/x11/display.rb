require 'xlib'

module Vigilem
module X11
  # 
  # 
  class Display < Xlib::Display
    
    @layout = superclass.layout
    
    # 
    # @param [Display || FFI::Pointer || String] 
    #          display_pointer_or_name
    def initialize(display_pointer_or_name)
      if display_pointer_or_name.is_a? ::FFI::Pointer
        super(display_pointer_or_name)
      else
        super(Xlib.XOpenDisplay(display_pointer_or_name))
      end
    end
    
    # 
    # @return [Fixnum]
    def fileno
      @fileno ||= self[:fd]
    end
    
    # 
    # @return [UNIXSocket]
    def to_io
      @io ||= UNIXSocket.for_fd(fileno)
    end
    
    class << self
      alias_method :open, :new
      
      # 
      # @param  [Display || FFI::Pointer || String] 
      #           display_obj_pointer_or_name
      # @return [Display]
      def wrap(display_obj_pointer_or_name)
        if display_obj_pointer_or_name.is_a? self
          display_obj_pointer_or_name
        else
          Display.open(display_obj_pointer_or_name)
        end
      end
      
    end
  end
  
end
end

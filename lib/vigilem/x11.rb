require 'xlib'

require 'vigilem/x11/display'

module Vigilem
module X11
  
 module_function
  
  # XQueryTree(Display *display, Window w, Window *root_return, 
  #                Window *parent_return, Window **children_return, 
  #                                   unsigned int *nchildren_return);
  # @see    man xquerytree
  # @param  [#to_ptr] display
  # @param  [Integer] w
  # @param  [Hash]
  # @option :root_return [::FFI::Pointer<:ulong>]
  # @option :parent_return [::FFI::Pointer<:ulong>]
  # @option :children_return [::FFI::Pointer]
  # @option :nchildren_return [::FFI::Pointer<:uint> || Integer]
  # @return [Fixnum] status
  def query_tree(display, w, opts={})
    opts[:root_return] ||= ::FFI::MemoryPointer.new(:ulong, 1)
    opts[:parent_return] ||=  ::FFI::MemoryPointer.new(:ulong, 1)
    opts[:children_return] ||= ::FFI::MemoryPointer.new(:ulong)
    opts[:nchildren_return] ||= ::FFI::MemoryPointer.new(:uint, 1)
    
    raise_nil_arg_error('display', display)
    raise_nil_arg_error('w', w)
    
    Xlib::XQueryTree(display, w, opts[:root_return], opts[:parent_return], 
                            opts[:children_return], opts[:nchildren_return])
    opts[:nchildren_return] = opts[:nchildren_return].read_uint
    opts.each do |k,v|
      opts[k] = v.read_ulong if opts[k].respond_to? :read_ulong
    end
  end
  
  # 
  # @param  [#to_ptr] display
  # @param  [Integer || ::FFI::Pointer] focus_return
  # @param  [Integer || ::FFI::Pointer] revert_to_return
  # @return [Array<Fixnum, Integer, Fixnum>] exit_code, xwindow id, revert_to_return
  def get_input_focus(display, focus_return, revert_to_return=nil)
    display = Vigilem::X11::Display.wrap(display)
    if not focus_return.is_a? ::FFI::MemoryPointer
      fr = focus_return
      focus_return = ::FFI::MemoryPointer.new(:int)
      focus_return.write_int(fr)
    end
    if not revert_to_return.is_a? ::FFI::MemoryPointer
      rtr = revert_to_return
      revert_to_return = ::FFI::MemoryPointer.new(:int)
      revert_to_return.write_int(rtr || 0)
    end
    raise_nil_arg_error('display', display)
    raise_nil_arg_error('focus_return', focus_return)
    [Xlib.XGetInputFocus(display, focus_return, revert_to_return), 
                        focus_return.read_int, revert_to_return.read_int]
  end
  
  def raise_nil_arg_error(name, val)
    raise ArgumentError, "#{name} is #{val.inspect}" if val.nil?
  end
end
end


require 'vigilem/x11/input_system_handler'

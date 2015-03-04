require 'vigilem/x11'

describe Vigilem::X11 do
  if Xlib.available?
    
    describe '::get_input_focus' do
      
      let(:display) { Vigilem::X11::Display.new(ENV['DISPLAY'] || ::FFI::MemoryPointer.new(:long, 296)) }
      
      let(:win_id) { 0x12123 }
      
=begin
      # this should work, but allow strips out the arguments (or something) and 
      # then ArgumentError: "Invalid Memory object" is raised
      it 'calls XGetInputFocus' do
        allow(Xlib).to receive(:XGetInputFocus).with(a_kind_of(::FFI::Struct), a_kind_of(Fixnum), a_kind_of(Fixnum))
        expect(Xlib).to receive(:XGetInputFocus).with(a_kind_of(::FFI::Struct), a_kind_of(Fixnum), a_kind_of(Fixnum))
        
        subject.get_input_focus
      end
=end
      it 'accepts [String],[Fixnum],[Fixnum] returns [Fixnum, Integer, Fixnum]' do
        expect(described_class.get_input_focus(display, win_id)).to match [
          a_kind_of(Fixnum), a_kind_of(Integer), a_kind_of(Fixnum)
        ]
      end
      
      it 'updates window ptr' do
        window = FFI::MemoryPointer.new(:ulong)
        window.write_ulong(win_id)
        described_class.get_input_focus(display, window)
        expect(window.read_int).not_to eql(win_id)
      end
      
      it 'updates revert_to_return ptr' do
        revert_to_return = FFI::MemoryPointer.new(:int)
        revert_to_return.write_int(0)
        described_class.get_input_focus(display, win_id)
        expect(revert_to_return.read_int).to be_a Fixnum
      end
    end
    
  end
end

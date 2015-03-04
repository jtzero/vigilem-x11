require 'spec_helper'

require 'vigilem/x11/input_system_handler'

describe Vigilem::X11::InputSystemHandler do
  
  subject { described_class.new(0x12123, (ENV['DISPLAY'] || ::FFI::MemoryPointer.new(:long, 296))) }
  
  after(:each) do
    [described_class, Vigilem::X11::EventQueue, Vigilem::Core::Demultiplexer, Vigilem::X11::Display].each do |klass|
      (klass.instance_variables - [:@layout]).each do |ivar|
        klass.send(:remove_instance_variable, ivar)
      end
    end
  end
  
  describe '#select_input' do
    it 'calls XSelectInput' do
      mask = Xlib::KeyPressMask | Xlib::FocusChangeMask
      allow(Xlib).to receive(:XSelectInput).with(mask)
      expect(Xlib).to receive(:XSelectInput).with(subject.demultiplexer.input.display, subject.window_xid, mask)
      subject.select_input(mask)
    end
  end
  
  describe '#initialize' do
    
    it 'sets up the window if the window_xid was given' do
      expect(subject.window_xid).to be_an Integer
    end
    
    it 'calls XSelectInput if passed in' do
      mask = Xlib::KeyPressMask | Xlib::FocusChangeMask
      allow(Xlib).to receive(:XSelectInput).with(mask)
      expect(Xlib).to receive(:XSelectInput)
      Vigilem::X11::EventQueue.all.replace([])
      described_class.new(0x1111, ::FFI::MemoryPointer.new(:long, 296), mask)
    end
  end
  
  describe '#read_many_nonblock' do
    it 'reads a max number of events from the event_queue' do
      allow(subject.demultiplexer.input).to receive(:shift) { [1,2,3] }
      expect(subject.read_many_nonblock(3)).to eql([1,2,3])
    end
    
    it 'calls #synchronize' do
      allow(subject.demultiplexer.input).to receive(:shift) { [1,2,3] }
      expect(subject).to receive(:synchronize)
      subject.read_many_nonblock(3)
    end
    
    it 'sets up the other eventable methods' do
      allow(subject.demultiplexer.input).to receive(:shift) { [1] }
      expect { subject.read_one_nonblock }.not_to raise_error and eql([1])
    end
  end
  
  describe '#get_input_focus' do
    it 'calls ::get_input_focus' do
      allow(Vigilem::X11).to receive(:get_input_focus)
      expect(Vigilem::X11).to receive(:get_input_focus).with(subject.display, subject.window_xid, 0) { [1,2,3] }
      subject.get_input_focus
    end
    
    if Xlib.available?
      it 'returns a Fixnum, and Integer' do
        allow(described_class).to receive(:get_input_focus).and_call_original
        expect(subject.get_input_focus).to match [a_kind_of(Fixnum), a_kind_of(Integer)]
      end
    end
  end
  
end

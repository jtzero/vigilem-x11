require 'spec_helper'

require 'vigilem/x11/event_queue'

describe Vigilem::X11::EventQueue do
  
  let(:dpy) { Vigilem::X11::Display.new(ENV['DISPLAY']) }
  
  after(:each) do
    [described_class, Vigilem::X11::Display].each do |klass|
      (klass.instance_variables - [:@layout]).each do |ivar|
        klass.send(:remove_instance_variable, ivar)
      end
    end
  end
  
  describe '::same_display_check' do
    
    it %q<checks the ::all for EventQueue's that have the same fileno> do
      ary = [double("EventQueue1", :display => dpy), double("EventQueue2", :display => dpy)]
      described_class.all.concat(ary)
      expect(described_class.same_display_check).to eql({ dpy.fileno => ary })
    end
    
  end
  
  describe '::same_display_check!' do
    
    it %q<checks the ::all for EventQueue's that have the same fileno and raises an Error if some exist> do
      ary = [double("EventQueue1", :display => dpy), double("EventQueue2", :display => dpy)]
      described_class.all.concat(ary)
      expect { described_class.same_display_check! }.to raise_error(ArgumentError)
    end
    
  end
  
  describe '#initialize' do
    it 'accepts a display obj' do
      expect do
        described_class.new(dpy)
      end.to_not raise_error and be_a described_class
    end
    
    it 'accepts a display pointer' do
      expect do 
        described_class.new(Xlib.XOpenDisplay(ENV['DISPLAY']))
      end.to_not raise_error and be_a described_class
    end
    
    it 'accepts a display_name' do
      expect do 
        described_class.new(ENV['DISPLAY'])
      end.to_not raise_error and be_a described_class
    end
    
  end
  
  describe '::new' do
    it 'adds the instance to ' do
      dpy = described_class.new(ENV['DISPLAY'])
      expect(described_class.all).to include(dpy)
    end
    
    it 'calls #same_display_check!' do
      ary = [double("EventQueue1", :display => dpy), double("EventQueue2", :display => dpy)]
      described_class.all.concat(ary)
      expect { described_class.new(dpy) }.to raise_error(ArgumentError)
    end
  end
  
  describe '::acquire' do
    it 'returns a new instance if none is found' do
      described_class.all.replace([])
      dspy = Vigilem::X11::Display.new(ENV['DISPLAY'])
      expect(described_class.acquire(dspy)).to be_a described_class
    end
    
    it 'returns the instance that has the same display#fileno' do
      evq = described_class.new(dpy)
      expect(described_class.acquire(dpy)).to eql(evq)
    end
  end
  
  describe '#pending!' do
    it 'gets the XPending value' do
      evq = described_class.new(dpy)
      num = 1
      allow(Xlib).to receive(:XPending) { num }
      expect(evq.pending!).to eql(num)
    end
  end
  
  describe '#pending' do
    it 'gets the XPending value and the size of the array not yet propagated' do
      evq = described_class.new(dpy)
      internal_buf = [Xlib::XEvent.new, Xlib::XEvent.new]
      evq.send(:_internal_buffer).concat(internal_buf)
      xpend_ret = 1
      allow(Xlib).to receive(:XPending) { xpend_ret }
      expect(evq.pending).to eql(xpend_ret + internal_buf.size)
    end
  end
  
  describe '#next_event' do
    it 'gets the next event from the xwindow event queue' do
      allow(Xlib).to receive(:XNextEvent)
      evq = described_class.new(dpy)
      expect(evq.next_event).to be_a Xlib::XEvent
    end
  end
  
  describe '#fileno' do
    it 'gets the fileno of the display' do
      evq = described_class.new(dpy)
      expect(evq.fileno).to eql(evq.fileno)
    end
  end
  
  describe '#slice!' do
    it 'will get the ' do
      evq = described_class.new(dpy)
      allow(evq).to receive(:pending!) { 1 }
      empty_event = Xlib::XEvent.new
      allow(evq).to receive(:next_event) { empty_event }
      expect(evq.slice!(0)).to eql(empty_event)
    end
  end
  
  describe '#concat' do
    it 'will error, not implemented' do
      evq = described_class.new(dpy)
      expect { evq.concat }.to raise_error(NotImplementedError)
    end
  end
  
  describe '#peek' do
    it 'will error, no implemented' do
      evq = described_class.new(dpy)
      expect { evq.concat }.to raise_error(NotImplementedError)
    end
  end
  
  context 'private' do
    describe '#_internal_buffer' do
      it 'defaults to an empty array' do
        evq = described_class.new(dpy)
        expect(evq.send(:_internal_buffer)).to eql([])
      end
    end
  end
  
end

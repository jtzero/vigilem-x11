require 'spec_helper'

require 'vigilem/x11/display'

describe Vigilem::X11::Display do
  
  after(:each) do
    [described_class].each do |klass|
      (klass.instance_variables - [:@layout]).each do |ivar|
        klass.send(:remove_instance_variable, ivar)
      end
    end
  end
  
  it 'is a subclass of Xlib::Display' do
    expect(described_class).to be < Xlib::Display
  end
  
  it 'has the same structure as Xlib::Display' do
    expect(described_class.layout).to eql(Xlib::Display.layout)
  end
  
  describe '#initialize' do
     it 'takes a pointer and creates a display from it' do
       expect do 
         described_class.new(Xlib.XOpenDisplay(ENV['DISPLAY'])) 
      end.not_to raise_error and be_a described_class
     end
     
     it 'takes a display name and creates a Display' do
       expect do 
         described_class.new(ENV['DISPLAY']) 
      end.not_to raise_error and be_a described_class
     end
  end
  
  context 'post_init' do
    subject { described_class.new(ENV['DISPLAY']) }
    
    describe '#fileno' do
      it 'returns the fileno of the associated IO' do
        expect(subject.fileno).to be_an Integer
      end
    end
    
    describe '#to_io' do
      it 'returns the display as IO' do
        expect(subject.to_io).to be_a IO
      end
    end
  end
  
  describe '::wrap' do
    it 'returns a new display object' do
      expect { described_class.wrap(ENV['DISPLAY']) }.not_to raise_error and be_a Display
    end
    
    it 'takes a pointer and creates a display from it' do
      expect { described_class.wrap(Xlib.XOpenDisplay(ENV['DISPLAY'])) }.not_to raise_error and be_a Display
    end
    
    it 'takes a Display object and returns the same Display object' do
      dpy = described_class.wrap(ENV['DISPLAY'])
      expect { described_class.wrap(dpy) }.not_to raise_error and eql(dpy)
    end
  end
  
  #describe '::open' do
  #  
  #end
  
end

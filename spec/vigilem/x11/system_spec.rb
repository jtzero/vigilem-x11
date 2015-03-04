require 'spec_helper'

require 'vigilem/x11/system'

describe Vigilem::X11::System do
  
  describe '::to_i!' do
    it 'returns an Integer if convertable' do
      expect(described_class.to_i!("1234.1234")).to eql(1234)
    end
    
    it 'returns an nil if not convertable' do
      expect(described_class.to_i!("Sjaldan er ein baran stok")).to be_nil
    end
    
    it 'returns 0 when the value is zero' do
      expect(described_class.to_i!("0")).to eql(0)
    end
    
    it 'returns 0 when the value is zero equivilant' do
      expect(described_class.to_i!(".00")).to eql(0)
    end
    
    it %q<doesn't return 0 if it contains zero> do
      expect(described_class.to_i!('83886092')).to eql(83886092)
    end
  end
  
  describe '::environ_file' do
    it 'defaults to the /proc/self/environ' do
      expect(described_class.environ_file.path).to eql("/proc/self/environ")
    end
    
    it 'gets the environ file of the pid passed in' do
      expect(described_class.environ_file(Process.pid).path).to eql("/proc/#{Process.pid}/environ")
    end
  end
  
  describe '::ppid_of' do
    it 'gets the ppid of the passed in pid' do
      expect(described_class.ppid_of(Process.pid)).to eql(Process.ppid)
    end
    
    it 'returns nil if ppid cannot be found' do
      expect(described_class.ppid_of(`cat /proc/sys/kernel/pid_max`.to_i + 1)).to be_nil
    end
  end
  
end

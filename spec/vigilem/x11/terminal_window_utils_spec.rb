require 'spec_helper'

require 'tempfile'

require 'vigilem/x11/terminal_window_utils'

describe Vigilem::X11::TerminalWindowUtils do
  
  describe '::window_id' do
    it 'returns the id of the window if it exists' do
      expect(described_class.window_id).to be > 0
    end
    
    it 'checks the environ_file if the ENV is empty' do
    
      ENV['WINDOWID'] = ''
      allow(described_class).to receive(:environ_file) { Tempfile.new('asdf') }
      expect(described_class).to receive(:environ_file)
      described_class.window_id
    end
    
    it 'returns traverses the pid tree to find an WINDOWID in the environ_file' do
      ENV['WINDOWID'] = ''
      allow(described_class).to receive(:environ_file) { Tempfile.new('asdf') }
      expect(described_class.window_id).to be_nil
    end
    
  end
end

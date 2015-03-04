module Vigilem
module X11
  module System
    # gets the 
    # @param  [Integer] pid
    # @return [Integer || NilClass]
    def ppid_of(pid)
      to_i!(`ps -p #{pid} -o ppid= 2>&1`.strip)
    end
    
    # 
    # @param  [Intger] pid
    # @return [File]
    def environ_file(pid='self')
      file_path = "#{File::SEPARATOR}#{File.join('proc', pid.to_s, 'environ')}"
      if test ?e, file_path
        @environ = File.open(file_path)
      end
    end
    
    # like #to_i but returns nil if not convertable
    # @todo   move to support/core_ext
    # @param  [String] str
    # @return [Integer || NilClass]
    def to_i!(str)
      if str =~ /^\s*(0+|(0*\.0+))\s*$/
        0
      else
        [str.to_i].find {|i| i != 0 }
      end
    end
    
    extend self
    
  end
end
end

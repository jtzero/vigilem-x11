require 'vigilem/x11/system'

module Vigilem
module X11
  # 
  # 
  module TerminalWindowUtils
   
   extend System
   
   module_function
    
    # gets the id of the window that spawned this 
    # ruby process
    # @return [Integer]
    def window_id
      return (env = to_i!(ENV['WINDOWID'])) if env
      
      curr_pid = Process.pid
      until curr_pid.to_i < 2
        file = environ_file(curr_pid)
        if file and (xid = to_i!(file.read.scan(/(?<=WINDOWID=)\d+/)[0]))
          return xid
        else
          curr_pid = ppid_of(curr_pid)
        end
      end
      
    end
    
  end
end
end

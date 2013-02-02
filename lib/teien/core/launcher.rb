module Teien

class Launcher
  @command = Hash.new

  def self.launch(argv)
    if @command[argv[0]]
      require 'teien'
      @command[argv[0]].call(argv) 
    else
      puts "Command List:"
      @command.each_key {|key|
        puts key
      }
    end
  end

  def self.set_command(command_name, method)
    @command[command_name] = method
  end
end

end

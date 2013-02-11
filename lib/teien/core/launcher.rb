module Teien

class Launcher
  @@argv = nil
  @command = Hash.new

  def self.launch(argv)
    @@argv = argv

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

  def self.register_command(command_name, method)
    @command[command_name] = method
  end

  def self.argv
    return @@argv
  end

end

end

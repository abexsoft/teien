require "teien/core/launcher"

module Teien

class LocalCommand
  def self.local_command(argv)
    pid = Process.fork {
      ServerCommand::start_server("0.0.0.0", 11922, 0.1)
    }
    begin
      BrowserCommand::start_browser("0.0.0.0", 11922)
    ensure
      Process.kill("TERM", pid)
    end
    
  end
  
  Launcher::register_command("local", LocalCommand.method(:local_command))
end

end

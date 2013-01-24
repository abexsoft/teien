module Teien

class StdCommand
  def self.server_command(argv)
    start_server_garden("0.0.0.0", 11922)
  end

  def self.client_command(argv)
    ip = argv[1] ? argv[1] : "0.0.0.0"
    port = argv[2] ? argv[2].to_i : 11922
    start_client_garden(ip, port)
  end

  def self.local_command(argv)
    start_local_garden()
  end

  def self.alone_command(argv)
    start_alone_garden()
  end


  def self.start_server_garden(ip, port, sync_period = 0.5)
    require "teien/synchronizer"
    Dir.glob("#{Dir.getwd}/app/models/*.rb") {|file|
      require "#{file}"
    }

    event_router = Teien::EventRouter.new()
    garden = Teien::Garden.new(event_router)
    Teien::Model.load(event_router, garden)

    Teien::register_component("event_router", event_router)
    Teien::register_component("garden", garden)
    Teien::register_component("synchronizer", Teien::Synchronizer.new(event_router, garden, sync_period))
    event_router.start_server(ip, port)
  end
  
  def self.start_client_garden(ip, port)
    require "teien/proxy_garden.rb"
    require 'teien/user_interface'
    Dir.glob("#{Dir.getwd}/app/controllers/*.rb") {|file|
      require "#{file}"
    }
    event_router = Teien::EventRouter.new()
    garden = Teien::ProxyGarden.new(event_router)
    ui = Teien::UserInterface.new(event_router, garden)
    Teien::Controller.load(event_router, garden)

    Teien::register_component("event_router", event_router)
    Teien::register_component("garden", garden)
    Teien::register_component("ui", ui )
    event_router.connect_to_server(ip, port)
  end
  
  def self.start_local_garden()
    require 'teien/user_interface'
    
    pid = Process.fork {
#      start_server_garden("0.0.0.0", 11922, 10)
      start_server_garden("0.0.0.0", 11922, 0.1)
    }
    begin
      start_client_garden("0.0.0.0", 11922)
    ensure
      Process.kill("TERM", pid)
    end
    
=begin
       garden = Teien::Garden.new()
       ui = Teien::UserInterface.new(garden)
       garden_script = garden_script_klass.new(garden)
       controller_script = controller_script_klass.new(garden, ui)
       garden.run
=end
  end

  def self.start_alone_garden()
    require "teien/garden.rb"
    require 'teien/user_interface'
    Dir.glob("#{Dir.getwd}/app/models/*.rb") {|file| require "#{file}" }
    Dir.glob("#{Dir.getwd}/app/controllers/*.rb") {|file| require "#{file}" }

    event_router = Teien::EventRouter.new()
    garden = Teien::Garden.new(event_router)
    ui =Teien::UserInterface.new(event_router, garden)
    Teien::Model.load(event_router, garden)
    Teien::Controller.load(event_router, garden)

    Teien::register_component("event_router", event_router)
    Teien::register_component("garden", garden)
    Teien::register_component("ui", ui)
    event_router.start_server()
  end

  Launcher::set_command("server", StdCommand.method(:server_command))
  Launcher::set_command("client", StdCommand.method(:client_command))
  Launcher::set_command("local",  StdCommand.method(:local_command))
  Launcher::set_command("alone",  StdCommand.method(:alone_command))
end

end

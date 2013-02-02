require "teien/core/launcher"

module Teien

class ServerCommand
  def self.server_command(argv)
    start_server("0.0.0.0", 11922)
  end

  def self.start_server(ip, port, sync_period = 0.5)
    require "teien/base_object/synchronizer"
    require 'teien/browser/browser_event'
    Dir.glob("#{Dir.getwd}/addons/*/server/*.rb") {|file| require "#{file}" }
    Dir.glob("#{Dir.getwd}/app/*.rb") {|file| require "#{file}" }

    event_router = Teien::EventRouter.new()
    Teien::register_component("event_router", event_router)

    base_object_manager = Teien::BaseObjectManager.new(event_router)
    Teien::register_component("base_object_manager", base_object_manager)

    sync = Teien::Synchronizer.new(event_router, base_object_manager, sync_period)
    Teien::register_component("synchronizer", sync)

#    Teien::Addon.load(event_router, base_object_manager)
    Teien::Model.load(event_router, base_object_manager)

    event_router.start_server(ip, port)
  end
  
  Launcher::set_command("server", ServerCommand.method(:server_command))
end

end

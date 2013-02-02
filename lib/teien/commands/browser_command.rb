require "teien/core/launcher"

module Teien

class BrowserCommand
  def self.browser_command(argv)
    ip = argv[1] ? argv[1] : "0.0.0.0"
    port = argv[2] ? argv[2].to_i : 11922

    start_browser(ip, port)
  end

  def self.start_browser(ip, port)
    require "teien/base_object/base_object_manager_proxy.rb"
    require 'teien/animation/animation'
    require 'teien/action/smooth_mover'
    require 'teien/ui/user_interface'
    require 'teien/browser/browser'
    Dir.glob("#{Dir.getwd}/addons/*/browser/*.rb") {|file| require "#{file}" }

    event_router = Teien::EventRouter.new()
    Teien::register_component("event_router", event_router)

    base_object_manager = Teien::BaseObjectManagerProxy.new(event_router)
    Teien::register_component("base_object_manager", base_object_manager)

    ui = Teien::UserInterface.new(event_router, base_object_manager)
    Teien::register_component("user_interface", ui )

    browser  = Teien::Browser.new(event_router, base_object_manager, ui)
    Teien::register_component("browser", browser)

#    Teien::Addon.load()

    event_router.connect_to_server(ip, port)
  end
  
  Launcher::set_command("browser", BrowserCommand.method(:browser_command))
end

end

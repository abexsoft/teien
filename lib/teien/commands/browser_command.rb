require "teien/core/launcher"

module Teien

class BrowserCommand
  def self.browser_command(argv)
    ip = argv[1] ? argv[1] : "0.0.0.0"
    port = argv[2] ? argv[2].to_i : 11922

    start_browser(ip, port)
  end

  def self.start_browser(ip, port)
    event_router = Teien::EventRouter.new()
    Teien::register_component("event_router", event_router)

    require "teien/base_object/base_object_manager_proxy"
    base_object_manager = Teien::BaseObjectManagerProxy.new(event_router)
    Teien::register_component("base_object_manager", base_object_manager)

    require 'teien/animation/animation_manager_proxy'
    animation_manager = Teien::AnimationManagerProxy.new(event_router)
    Teien::register_component("animation_manager", animation_manager)

    require 'teien/actor/actor_manager_proxy'
    actor_manager = Teien::ActorManagerProxy.new()
    Teien::register_component("actor_manager", actor_manager)

    require 'teien/ui/user_interface'
    ui = Teien::UserInterface.new(event_router, base_object_manager)
    Teien::register_component("user_interface", ui )

    require 'teien/addon/addon'
    Teien::Addon::load()

    require 'teien/application/application'
    Teien::Application::load("browser")
    Teien::Application::instantiate()

    event_router.connect_to_server(ip, port)
  end
  
  Launcher::register_command("browser", BrowserCommand.method(:browser_command))
end

end

require "teien/core/launcher"

module Teien

class ServerCommand
  def self.server_command(argv)
    start_server("0.0.0.0", 11922)
  end

  def self.start_server(ip, port, sync_period = 0.1)
    event_router = Teien::EventRouter.new()
    Teien::register_component("event_router", event_router)

    require "teien/base_object/base_object_manager"
    base_object_manager = Teien::BaseObjectManager.new(event_router, sync_period)
    Teien::register_component("base_object_manager", base_object_manager)

    require 'teien/animation/animation_manager'
    animation_manager = Teien::AnimationManager.new(event_router)
    Teien::register_component("animation_manager", animation_manager)

    require 'teien/actor/actor_manager'
    actor_manager = Teien::ActorManager.new()
    Teien::register_component("actor_manager", actor_manager)

    require 'teien/addon/addon'
    Teien::Addon::load()

    require 'teien/application/application'
    Teien::Application::load("server")
    Teien::Application::instantiate()
    
    event_router.start_server(ip, port)
  end
  
  Launcher::register_command("server", ServerCommand.method(:server_command))
end

end

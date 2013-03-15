module Teien

class ServerApplication
  def initialize(sync_period = 0.3)
    require 'teien'

    @event_router = Teien::EventRouter.new()
    Teien::register_component("event_router", @event_router)

    require "teien/base_object/base_object_manager"
    @base_object_manager = Teien::BaseObjectManager.new(sync_period)
    Teien::register_component("base_object_manager", @base_object_manager)

    require 'teien/animation/animation_manager'
    @animation_manager = Teien::AnimationManager.new()
    Teien::register_component("animation_manager", @animation_manager)

    require 'teien/actor/actor_manager'
    @actor_manager = Teien::ActorManager.new()
    Teien::register_component("actor_manager", @actor_manager)
  end

  def start_server(ip, port)
    @event_router.start_server(ip, port)
  end
end

end

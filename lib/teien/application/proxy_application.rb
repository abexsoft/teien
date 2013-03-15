module Teien

class ProxyApplication
  def initialize()
    require 'teien'

    @event_router = Teien::EventRouter.new()
    Teien::register_component("event_router", @event_router)
    
    require "teien/base_object/base_object_manager_proxy"
    @base_object_manager = Teien::BaseObjectManagerProxy.new()
    Teien::register_component("base_object_manager", @base_object_manager)
    
    require 'teien/animation/animation_manager_proxy'
    @animation_manager = Teien::AnimationManagerProxy.new()
    Teien::register_component("animation_manager", @animation_manager)
    
    require 'teien/actor/actor_manager_proxy'
    @actor_manager = Teien::ActorManagerProxy.new()
    Teien::register_component("actor_manager", @actor_manager)
  end

  def connect_to_server(ip, port)
    @event_router.connect_to_server(ip, port)
  end
end

end

require_relative "actor_factory"
require_relative "actor_event"
require_relative "actor"
require_relative "actor_info"

module Teien

class ActorManager
  attr_accessor :actors

  def initialize()
    @actors = Hash.new
    @event_router = Teien::get_component("event_router")
    @event_router.register_receiver(self)
  end

  def create_actor(actor_info)
    actor = ActorFactory::create_actor(actor_info)
    @actors[actor_info.actor_name] = actor
    actor
  end

  def update(delta)
    @actors.each_value {|actor|
      actor.update(delta)
    }
  end

end

end

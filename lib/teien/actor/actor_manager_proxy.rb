require_relative "actor_factory"
require_relative "actor_event"
require_relative "actor"
require_relative "actor_info"

module Teien

class ActorManagerProxy
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

  def receive_event(event, from)
    case event
    when Teien::Event::Actor::SyncActor
      if @actors[event.actor_info.actor_name]
        # sync some stuff. (ex. state)
        @actors[event.actor_info.actor_name].receive_event(event, from)
      else
        @actors[event.actor_info.actor_name] = create_actor(event.actor_info)
      end
    when Teien::Event::Actor::SetForwardDirection
      if @actors[event.actor_name]
        @actors[event.actor_name].set_forward_direction(event.dir)
      else
        puts "no actor_name"
      end
    when Teien::Event::Actor::EnableAction
      if event.forward
        @actors[event.actor_name].move_forward(true)
      elsif event.backward
        @actors[event.actor_name].move_backward(true)
      elsif event.left
        @actors[event.actor_name].move_left(true)
      elsif event.right
        @actors[event.actor_name].move_right(true)
      elsif event.jump
        @actors[event.actor_name].jump(true)
      end
    when Teien::Event::Actor::DisableAction
      if event.forward
        @actors[event.actor_name].move_forward(false)
      elsif event.backward
        @actors[event.actor_name].move_backward(false)
      elsif event.left
        @actors[event.actor_name].move_left(false)
      elsif event.right
        @actors[event.actor_name].move_right(false)
      elsif event.jump
        @actors[event.actor_name].jump(false)
      end
    end
  end
end

end

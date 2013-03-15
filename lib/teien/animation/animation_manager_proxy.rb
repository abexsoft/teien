require "teien/animation/animation"
require "teien/animation/animation_event"

module Teien

class AnimationManagerProxy
  attr_accessor :animations

  def initialize()
    @animations = Hash.new
    @event_router = Teien::get_component("event_router")
    @event_router.register_receiver(self)
  end

  def create_animation(object_name)
    @animations[object_name] = Animation.new
  end

  def receive_event(event, from)
    case event
    when Teien::Event::Animation::SyncAnimation
      @animations[event.object_name] = event.animation
    end
  end
end

end

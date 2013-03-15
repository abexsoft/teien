require "teien/animation/animation"
require "teien/animation/animation_event"

module Teien

class AnimationManager
  attr_accessor :animations

  def initialize()
    @animations = Hash.new
    @event_router = Teien::get_component("event_router")
    @event_router.register_receiver(self)
  end

  def create_animation(object_name)
    @animations[object_name] = Animation.new
  end

  def update(delta)
  end
end

end

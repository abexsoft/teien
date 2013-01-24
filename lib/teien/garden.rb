require "teien/garden_base.rb"
require "teien/network.rb"
require "teien/event.rb"

module Teien

class Garden < GardenBase
  def initialize(event_router)
    super(event_router)
  end

  # EventRouter handler
  def setup()
    @physics.setup(self)
  end

  # EventRouter handler
  def update(delta)
    @physics.update(delta)
    @actors.each_value {|actor|
      actor.update(delta)
    }
    return !@quit
  end

  # EventRouter handler
  def connection_binded(from)
    @event_router.send_event(Event::SyncEnv.new(@gravity, @ambient_light_color, @sky_dome), from)
    notify_objects(from)
  end

  def notify_objects(to = nil)
    @objects.each_value { |obj|
      if to
        to.send_object(Event::SyncObject.new(obj))
      else
        @event_router.send_event(Event::SyncObject.new(obj))
      end
    }
  end

  def finalize()
    @physics.finalize()
    @objects = {}
  end

end

end

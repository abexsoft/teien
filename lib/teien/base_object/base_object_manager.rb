require "teien/base_object/base_object_manager_base.rb"
require "teien/core/network.rb"
require "teien/base_object/base_object_event.rb"

module Teien

class BaseObjectManager < BaseObjectManagerBase
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
    return !@quit
  end

  # EventRouter handler
  def connection_binded(from)
    @event_router.send_event(Event::BaseObject::SyncEnv.new(@gravity, @ambient_light_color, @sky_dome), from)
    notify_objects(from)
  end

  def notify_objects(to = nil)
    @objects.each_value { |obj|
      if to
        to.send_object(Event::BaseObject::SyncObject.new(obj))
      else
        @event_router.send_event(Event::BaseObject::SyncObject.new(obj))
      end
    }
  end

  def finalize()
    @physics.finalize()
    @objects = {}
  end

end

end

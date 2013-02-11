require "teien/base_object/base_object_manager_base.rb"
require "teien/core/network.rb"
require "teien/base_object/base_object_event.rb"

module Teien

class BaseObjectManager < BaseObjectManagerBase
  def initialize(event_router, sync_period)
    super(event_router)
    @sync_period = sync_period
    @sync_timer = sync_period
  end

  # EventRouter handler
  def setup()
    
    @physics.setup(self)
  end

  # EventRouter handler
  def update(delta)
    @physics.update(delta)

    @sync_timer += delta
    if (@sync_timer > @sync_period)
      notify_objects()
      @sync_timer = 0
    end

    return !@quit
  end

  # EventRouter handler
  def connection_binded(from)
    event = Event::BaseObject::SyncEnv.new(@gravity, @ambient_light_color, @sky_dome)
    @event_router.send_event(event, from)
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

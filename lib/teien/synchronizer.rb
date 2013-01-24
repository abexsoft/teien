module Teien

class Synchronizer
  def initialize(event_router, garden, sync_period)
    @event_router = event_router
    @event_router.register_receiver(self)
    @garden = garden
    @sync_period = sync_period
    @sync_timer = sync_period
  end

  # EventRouter handler
  def update(delta)
    @sync_timer += delta
    if (@sync_timer > @sync_period)
      @garden.notify_objects()
      @sync_timer = 0
    end
  end
end

end

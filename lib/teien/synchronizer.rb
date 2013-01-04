module Teien

class Synchronizer
  def initialize(garden, sync_period)
    @garden = garden
    @garden.register_receiver(self)
    @sync_period = sync_period
    @sync_timer = sync_period
  end

  def setup(garden)
  end

  def update(delta)
    @sync_timer += delta
    if (@sync_timer > @sync_period)
      @garden.notify_objects()
      @sync_timer = 0
    end
  end

  def add_actor(actor)
  end
end

end

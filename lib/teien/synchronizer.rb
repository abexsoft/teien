module Teien

class Synchronizer
  SYNC_PERIOD = 0.1
  def initialize(garden)
    @garden = garden
    @garden.register_receiver(self)

    @sync_timer = 0
  end

  def setup(garden)
  end

  def update(delta)
    @sync_timer += delta
    if (@sync_timer > SYNC_PERIOD)
      @garden.notify_objects()
      @sync_timer = 0
    end
  end
end

end

module Teien

class Synchronizer
  def initialize(garden)
    @garden = garden
    @garden.register_receiver(self)

    @sync_timer = 0
  end

  def setup(garden)
  end

  def update(delta)
    @sync_timer += delta
    if (@sync_timer > 0.5)
      @garden.notify_objects()
      @sync_timer = 0
    end
  end
end

end

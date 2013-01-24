require 'teien'

module Teien

class Controller
  @@controllers = Array.new
  @@loaded_controllers = Array.new

  def initialize(event_router, garden)
    @event_router = event_router
    @event_router.register_receiver(self)
    @garden = garden
    @garden.register_receiver(self)
  end

  def self.inherited(klass)
    @@controllers.push(klass)
  end

  def self.load(event_router, garden)
    @@controllers.each {|ctl|
      @@loaded_controllers.push(ctl.new(event_router, garden))
    }
  end
end

end

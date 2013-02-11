module Teien

class Actor
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  ##
  # handlers of ActorManager
  #

  def update(delta)
  end

  def receive_event(event, from)
  end
end

end

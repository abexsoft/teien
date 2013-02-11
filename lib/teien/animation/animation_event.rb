module Teien
module Event
module Animation

class SyncAnimation
  attr_accessor :object_name
  attr_accessor :animation

  def initialize(object_name, animation)
    @object_name = object_name
    @animation = animation
  end
end

end
end
end

module Teien
module Event
module Actor

  class SyncActor
    attr_accessor :actor_info

    def initialize(actor_info)
      @actor_info = actor_info
    end
  end

  module Action
    attr_accessor :actor_name
    attr_accessor :forward
    attr_accessor :backward
    attr_accessor :left
    attr_accessor :right
    attr_accessor :jump

    def reset()
      @forward = false
      @backward = false
      @left = false
      @right = false
      @jump = false
    end

    def copy(event)
      @actor_name = event.actor_name
      @forward = event.forward
      @backward = event.backward
      @left = event.left
      @right = event.right
      @jump = event.jump
    end

  end

  class EnableAction
    include Action

    def initialize(name)
      @actor_name = name
      reset()
    end
  end

  class DisableAction
    include Action

    def initialize(name)
      @actor_name = name
      reset()
    end
  end
    
  class SetForwardDirection
    attr_accessor :actor_name
    attr_accessor :dir

    def initialize(name = nil, dir = nil)
      @actor_name = name
      @dir = dir
    end

    def copy(event)
      @actor_name = event.actor_name
      @dir = event.dir
    end
  end

  class RequestEnableAction < EnableAction
  end

  class RequestDisableAction < DisableAction
  end

  class RequestSetForwardDirection < SetForwardDirection
  end

end
end
end

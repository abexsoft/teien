require 'teien/event.rb'

module Event
  class RequestControllable
    def initialize()
    end
  end

  class ControllableObject
    attr_accessor :actor_name
    attr_accessor :object_name

    def initialize(actor_name, object_name)
      @actor_name = actor_name
      @object_name = object_name
    end
  end

  class SyncSinbad
    attr_accessor :actor_name
    attr_accessor :object_name

    def initialize(actor)
      @actor_name = actor.name
      @object_name = actor.object.name
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

  class RequestSetForwardDirection < SetForwardDirection
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

  class RequestEnableAction < EnableAction
  end

  class DisableAction
    include Action

    def initialize(name)
      @actor_name = name
      reset()
    end
  end
    
  class RequestDisableAction < DisableAction
  end

end

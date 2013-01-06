require 'teien/event.rb'

module Event
  class RequestControllable < EventBase
    def initialize()
      super(true)
    end
  end

  class ControllableObject < EventBase
    attr_accessor :actor_name
    attr_accessor :object_name

    def initialize(actor_name, object_name)
      super(true)
      @actor_name = actor_name
      @object_name = object_name
    end
  end

  class SyncSinbad < EventBase
    attr_accessor :actor_name
    attr_accessor :object_name

    def initialize(actor)
      super(true)
      @actor_name = actor.name
      @object_name = actor.object.name
    end
  end

  class SetForwardDirection < EventBase
    attr_accessor :actor_name
    attr_accessor :dir

    def initialize(name, dir)
      super(true)
      @actor_name = name
      @dir = dir
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

  end

  class EnableAction < EventBase
    include Action

    def initialize(name)
      super(true)
      @actor_name = name
      reset()
    end
  end

  class DisableAction < EventBase
    include Action

    def initialize(name)
      super(true)
      @actor_name = name
      reset()
    end
  end
    
end

module Teien
module Event
  class KeyPressed
    attr_accessor :key

    def initialize(key)
      @key = key
    end
  end

  class KeyReleased
    attr_accessor :key

    def initialize(key)
      @key = key
    end
  end

  module MouseAction
    attr_reader :button_id
    attr_reader :width
    attr_reader :height
    attr_reader :x_abs
    attr_reader :y_abs
    attr_reader :z_abs
    attr_reader :x_rel
    attr_reader :y_rel
    attr_reader :z_rel
    attr_reader :camera_pos
    attr_reader :camera_dir

    def initialize(mouse_event, mouse_button_id, camera)
      @button_id = mouse_button_id
      @width = mouse_event.state.width
      @height = mouse_event.state.height
      @x_abs = mouse_event.state.X.abs
      @y_abs = mouse_event.state.Y.abs
      @z_abs = mouse_event.state.Z.abs
      @x_rel = mouse_event.state.X.rel
      @y_rel = mouse_event.state.Y.rel
      @z_rel = mouse_event.state.Z.rel
      @camera_pos = camera.get_position()
      @camera_dir = camera.get_direction()
    end
  end

  class MousePressed
    include MouseAction
  end

  class MouseReleased
    include MouseAction
  end

  class ReadyToGo
  end

  class ControllableActor
    attr_accessor :actor_name

    def initialize(actor_name)
      @actor_name = actor_name
    end
  end


end
end


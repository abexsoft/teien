class SinbadState
  def initialize(parent)
    @state = nil
    @prevState = nil
    @stateHash = {}
    @stateHash["Stop"] = Stop.new(parent)
    @stateHash["Run"] = Run.new(parent)
    @stateHash["GravityFree"] = GravityFree.new(parent)
    @stateHash["InAir"] = InAir.new(parent)
    @stateHash["Jump"] = Jump.new(parent)
    @stateHash["JumpLoop"] = JumpLoop.new(parent)
    @stateHash["JumpEnd"] = JumpEnd.new(parent)
    set_state("Stop")

  end

  def set_state(state)
    nextState = @stateHash[state]
    if (!@state.equal?(nextState))
      @state.fini() if (@state != nil)
      @prevState = @state
      @state = nextState

      puts state 

      @state.init() if(@state != nil)
      return true
    end
    return false
  end

  def set_prev_state()
    return false if (@prevState == nil)

    @state.fini() if (@state != nil)
    @state = @prevState
    @prevState = nil
    @state.init() if(@state != nil)
    return true
  end

  def state?(name)
    return @state == @stateHash[name]
  end

  def update(delta)
    @state.update(delta)
  end


#
# define all of this actor states.
#
  class Stop
    def initialize(parent)
      @parent = parent
    end
    def init()
      @parent.play_top_animation("IdleTop")
      @parent.play_base_animation("IdleBase")
      @parent.object.set_damping(0.9, 0)
    end
    def update(delta)
      unless @parent.check_on_ground()
        @parent.state.set_state("InAir")
        return
      end

      @parent.mover.update_target(delta)
      if (@parent.mover.moving?())
        @parent.state.set_state("Run")
      end
    end
    def fini()
    end
  end

  class Run
    def initialize(parent)
      @parent = parent
    end

    def init()
      @parent.play_top_animation("RunTop")
      @parent.play_base_animation("RunBase")
      @parent.object.set_damping(0.0, 0)
      @parent.object.set_max_horizontal_velocity(17.0)
    end

    def update(delta)
      @parent.mover.update_target(delta)
      unless (@parent.mover.moving?())
        @parent.state.set_state("Stop")
      end
    end

    def fini()
    end
  end

  class GravityFree
    def initialize(parent)
      @parent = parent
    end

    def init()
      @parent.play_top_animation("IdleTop")
      @parent.play_base_animation("IdleBase")
      @parent.object.set_damping(0, 0)

      grav = @parent.object.get_gravity()
      puts "gravity: (#{grav.x}, #{grav.y}, #{grav.z})"
      @parent.object.set_gravity(Vector3D.new(0, 0, 0))

      @parent.mover = @parent.grav_mover
    end

    def update(delta)
      @parent.mover.update_target(delta)
    end

    def fini()
      @parent.object.set_gravity(Vector3D.new(0, -9.8, 0))
      @parent.mover = @parent.sm_mover
    end
  end

  class InAir
    def initialize(parent)
      @parent = parent
    end

    def init()
      @parent.play_top_animation("IdleTop")
      @parent.play_base_animation("IdleBase")
      @parent.object.set_damping(0, 0)

      @parent.object.set_gravity(Vector3D.new(0, -9.8, 0))
    end

    def update(delta)
      if @parent.check_on_ground()
        @parent.state.set_state("Stop")
      end
    end

    def fini()
    end
  end

  class Jump
    def initialize(parent)
      @parent = parent
    end

    def init()
      @parent.play_top_animation("IdleTop")
      @parent.play_base_animation("JumpStart")
      @parent.object.set_damping(0, 0)

      @parent.object.set_gravity(Vector3D.new(0, -9.8, 0))
      @parent.object.set_acceleration(Vector3D.new(0, 39.8, 0))
      @timer = 0
    end

    def update(delta)
      @timer += delta

#      if @timer > @parent.object.entity.get_animation_state("JumpStart").get_length()
      if @timer > 0.1
        @parent.state.set_state("JumpLoop")
      end
    end

    def fini()
    end
  end

  class JumpLoop
    def initialize(parent)
      @parent = parent
    end

    def init()
      @parent.play_top_animation("IdleTop")
      @parent.play_base_animation("JumpLoop")
      @parent.object.set_damping(0, 0)
      @parent.object.set_acceleration(Vector3D.new(0, 0.0, 0))
    end

    def update(delta)
      if @parent.check_on_ground()
        @parent.state.set_state("JumpEnd")
      end
    end

    def fini()
    end
  end


  class JumpEnd
    def initialize(parent)
      @parent = parent
    end

    def init()
      @parent.play_top_animation("IdleTop")
      @parent.play_base_animation("JumpEnd")
      @parent.object.set_damping(0, 0)

      @parent.object.set_gravity(Vector3D.new(0, -9.8, 0))
    end

    def update(delta)
      @parent.state.set_state("Stop")
    end

    def fini()
    end
  end

end


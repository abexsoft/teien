class AnimationOperator
  BL_MODE_SWITCH = 0      # stop current animation and start next animation.
  BL_MODE_CONCURRENT = 1  # cross fade, blend current animation out while blending next animation in.
  BL_MODE_FIRSTFRAME = 2  # blend current animation to first frame of next animation, when done, start next animation.

  attr_accessor :name
  attr_accessor :loop

  def initialize(entity)
    @entity = entity
    @state = nil
    @nextState = nil
    @mode = BL_MODE_CONCURRENT
    @duration = 0.2
    @timeLeft = 0
    @complete = false

    @name = nil
    @loop = false

#    @blender = Ogrelet::AnimationBlender.new(entity)
  end

  def init(name, loop)
    initialize_all_animations()
    play(name, loop)
  end

  def initialize_all_animations()
    set = @entity.get_all_animation_states()
    set.each_animation_state {|state|
      state.set_enabled(false)
      state.set_weight(0)
      state.set_time_position(0)
    }
  end

  def set_enabled(bl)
#    @blender.getSource().setEnabled(bl)
  end

  def set_blending_mode(mode)
    @mode = mode
  end

  def set_blenging_duration(duration)
    @duration = duration
  end

  def play(name, loop)
    @name = name
    @loop = loop

    unless @state
      @state = @entity.get_animation_state(name)
      @state.set_enabled(true)
      @state.set_weight(1)
      @state.set_time_position(0)
      @state.set_loop(loop)
      return
    end

    case @mode
    when BL_MODE_SWITCH
      @state.set_enabled(false)
      @state = @entity.get_animation_state(name)
      @state.set_enabled(true)
      @state.set_weight(1)
      @state.set_time_position(0)
      @timeLeft = 0
    else
      newState = @entity.get_animation_state(name)
      if @timeLeft > 0
        if newState.get_animation_name == @nextState.get_animation_name
          return
        elsif newState.get_animation_name == @state.get_animation_name
          # going back to the source state
          @state = @nextState
          @nextState = newState
          @timeLeft = @duration - @timeLeft
        else
          if @timeLeft < @duration * 0.5
            # simply replace the target with this one
            @nextState.set_enabled(false)
            @nextState.set_weight(0)
          else
            # old target becomes new source
            @state.set_enabled(false)
            @state.set_weight(0)
            @state = @nextState
          end

          @nextState = newState
          @nextState.set_enabled(true)
          @nextState.set_weight( 1.0 - @timeLeft / @duration )
          @nextState.set_time_position(0)
        end
      else
        return if newState.get_animation_name == @state.get_animation_name
                  
        # assert( target == 0, "target should be 0 when not blending" )
        # @state.setEnabled(true)
        # @state.setWeight(1)
        # mTransition = transition;
        @timeLeft = @duration
        @nextState = newState
        @nextState.set_enabled(true)
        @nextState.set_weight(0)
        @nextState.set_time_position(0)
      end
    end
#    @blender.blend(name, Ogrelet::AnimationBlender::BlendWhileAnimating, 0.2, loop)
  end

  def add_time(delta)
    if @state
      if @timeLeft > 0
        @timeLeft -= delta
        
        if @timeLeft < 0
          @state.set_enabled(false)
          @state.set_weight(0)
          @state = @nextState
          @state.set_enabled(true)
          @state.set_weight(1)
          @nextState = nil
        else
          # still blending, advance weights
          @state.set_weight(@timeLeft / @duration)
          @nextState.set_weight(1.0 - @timeLeft / @duration)
          if(@mode  == BL_MODE_CONCURRENT)
            @nextState.add_time(delta)
          end
        end
      end
      
      if @state.get_time_position() >= @state.get_length()
        @complete = true
      else
        @complete = false
      end

      @state.add_time(delta)
      @state.set_loop(@loop)
    end
    #    @blender.addTime(delta)
  end
end

class AnimationOperator
  BL_MODE_SWITCH = 0      # stop current animation and start next animation.
  BL_MODE_CONCURRENT = 1  # cross fade, blend current animation out while blending next animation in.
  BL_MODE_FIRSTFRAME = 2  # blend current animation to first frame of next animation, when done, start next animation.

  def initialize(entity)
    @entity = entity
    @state = nil
    @nextState = nil
    @mode = BL_MODE_CONCURRENT
    @duration = 0.2
    @timeLeft = 0
    @complete = false
    @loop = false

#    @blender = Ogrelet::AnimationBlender.new(entity)
  end

  def init(name, loop)
    initializeAllAnimations()
    play(name, loop)
  end

  def initializeAllAnimations()
    set = @entity.getAllAnimationStates()
    set.each_AnimationState {|state|
      state.setEnabled(false)
      state.setWeight(0)
      state.setTimePosition(0)
    }
  end

  def setEnabled(bl)
#    @blender.getSource().setEnabled(bl)
  end

  def setBlendingMode(mode)
    @mode = mode
  end

  def setBlengingDuration(duration)
    @duration = duration
  end

  def play(name, loop)
    @loop = loop

    unless @state
      @state = @entity.getAnimationState(name)
      @state.setEnabled(true)
      @state.setWeight(1)
      @state.setTimePosition(0)
      @state.setLoop(loop)
      return
    end

    case @mode
    when BL_MODE_SWITCH
      @state.setEnabled(false)
      @state = @entity.getAnimationState(name)
      @state.setEnabled(true)
      @state.setWeight(1)
      @state.setTimePosition(0)
      @timeLeft = 0
    else
      newState = @entity.getAnimationState(name)
      if @timeLeft > 0
        if newState.getAnimationName == @nextState.getAnimationName
          return
        elsif newState.getAnimationName == @state.getAnimationName
          # going back to the source state
          @state = @nextState
          @nextState = newState
          @timeLeft = @duration - @timeLeft
        else
          if @timeLeft < @duration * 0.5
            # simply replace the target with this one
            @nextState.setEnabled(false)
            @nextState.setWeight(0)
          else
            # old target becomes new source
            @state.setEnabled(false)
            @state.setWeight(0)
            @state = @nextState
          end

          @nextState = newState
          @nextState.setEnabled(true)
          @nextState.setWeight( 1.0 - @timeLeft / @duration )
          @nextState.setTimePosition(0)
        end
      else
        return if newState.getAnimationName == @state.getAnimationName
                  
        # assert( target == 0, "target should be 0 when not blending" )
        # @state.setEnabled(true)
        # @state.setWeight(1)
        # mTransition = transition;
        @timeLeft = @duration
        @nextState = newState
        @nextState.setEnabled(true)
        @nextState.setWeight(0)
        @nextState.setTimePosition(0)
      end
    end
#    @blender.blend(name, Ogrelet::AnimationBlender::BlendWhileAnimating, 0.2, loop)
  end

  def addTime(delta)
    if @state
      if @timeLeft > 0
        @timeLeft -= delta
        
        if @timeLeft < 0
          @state.setEnabled(false)
          @state.setWeight(0)
          @state = @nextState
          @state.setEnabled(true)
          @state.setWeight(1)
          @nextState = nil
        else
          # still blending, advance weights
          @state.setWeight(@timeLeft / @duration)
          @nextState.setWeight(1.0 - @timeLeft / @duration)
          if(@mode  == BL_MODE_CONCURRENT)
            @nextState.addTime(delta)
          end
        end
      end
      
      if @state.getTimePosition() >= @state.getLength()
        @complete = true
      else
        @complete = false
      end

      @state.addTime(delta)
      @state.setLoop(@loop)
    end
    #    @blender.addTime(delta)
  end
end

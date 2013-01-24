require 'teien'
require_relative '../../app/helpers/user_event'
require_relative '../../app/helpers/sinbad/sinbad'

include Teien

class ActorAi
  def initialize(garden)
    @garden = garden
    @garden.register_receiver(self)
  end

  def setup(garden)
    @quit = false
    @actor = nil

    @first_update = true
    @moveTime = 1.0
    @active = false
  end

  def update(delta)
    if @first_update
      event = Event::RequestControllable.new()
      @garden.send_event(event)
      @first_update = false
    end

    if @actor

      if @moveTime > 0
        unless @leftActive
          @leftActive = true
          @rightActive = false
          @moveTime = 2.0
          event = Event::DisableAction.new(@actor.name)
          event.right = true
          @garden.send_event(event)

          event = Event::EnableAction.new(@actor.name)
          event.left = true
          @garden.send_event(event)

          puts "left"
        end
        @moveTime -= delta
      else
        unless @rightActive
          @rightActive = true
          @leftActive = false
          @moveTime = -2.0
          @active = false
          event = Event::DisableAction.new(@actor.name)
          event.left = true
          @garden.send_event(event)
          
          event = Event::EnableAction.new(@actor.name)
          event.right = true
          @garden.send_event(event)
          puts "right"
        end
        @moveTime += delta
      end

      event = Event::SetForwardDirection.new(@actor.name, Vector3D.new(1.0, 0.0, 0.0))
#      @garden.actors[event.actor_name].set_forward_direction(event.dir)
      @garden.send_event(event)
#      event = Event::SetForwardDirection.new(@actor.name, Vector3D.to_self(@camera_mover.camera.get_direction()))
#      

    end
  end

  def receive_event(event, from)
    case event
    when Event::SyncSinbad
      unless (@garden.actors[event.actor_name])
        actor = Sinbad.load_event(@garden, event)
        @garden.actors[event.actor_name] = actor
      end
#      puts "SyncSindbad: #{event.actor_name}"
    when Event::ControllableObject
      @actor = @garden.actors[event.actor_name]
      puts event.actor_name
      puts @actor

     when Event::SetForwardDirection
      if @garden.actors[event.actor_name]
        @garden.actors[event.actor_name].set_forward_direction(event.dir)
      end
    when Event::EnableAction
      if event.forward
        @garden.actors[event.actor_name].move_forward(true)
      elsif event.backward
        @garden.actors[event.actor_name].move_backward(true)
      elsif event.left
        @garden.actors[event.actor_name].move_left(true)
      elsif event.right
        @garden.actors[event.actor_name].move_right(true)
      elsif event.jump
        @garden.actors[event.actor_name].jump(true)
      end
    when Event::DisableAction
      if event.forward
        @garden.actors[event.actor_name].move_forward(false)
      elsif event.backward
        @garden.actors[event.actor_name].move_backward(false)
      elsif event.left
        @garden.actors[event.actor_name].move_left(false)
      elsif event.right
        @garden.actors[event.actor_name].move_right(false)
      elsif event.jump
        @garden.actors[event.actor_name].jump(false)
      end
    end
  end
end

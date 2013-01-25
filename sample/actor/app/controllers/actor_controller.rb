require 'teien'
require_relative '../common/user_event'
require_relative '../common/sinbad/sinbad'

include Teien

class ActorController < Teien::Controller
  def setup()
    @quit = false
    @actor = nil
    @first_update = true

    @ui = Teien::get_component("ui")
    @ui.register_receiver(self)

    @camera_mover = @ui.get_camera().get_mover()
    @camera_mover.set_position(Vector3D.new(0, 10, 0))
    @camera_mover.look_at(Vector3D.new(0, 0, 0))

    @ui.show_frame_stats(UI::TL_BOTTOMLEFT)
    @ui.show_logo(UI::TL_BOTTOMRIGHT)
    @ui.hide_cursor()
  end

  def connection_completed(from)
    event = Event::RequestControllable.new()
    @event_router.send_event(event)
  end

  def update(delta)
    @camera_mover.update(delta)

    if @actor
      event = Event::RequestSetForwardDirection.new(@actor.name, 
                                                    Vector3D.to_self(@camera_mover.camera.get_direction()))
      @event_router.send_event(event)
#      @actor.set_forward_direction(event.dir) 
    end
  end

  def receive_event(event, from)
    case event
    when Event::SyncSinbad
      unless (@garden.actors[event.actor_name])
        puts "new Sindbad: #{event.actor_name}"        
        actor = Sinbad.load_event(@garden, event)
        @garden.actors[event.actor_name] = actor
      end

    when Event::ControllableObject
      @actor = @garden.actors[event.actor_name]
      puts event.actor_name
      puts @actor

      @camera_mover.set_style(CameraMover::CS_TPS)
      @camera_mover.set_target(@actor.object)
    when Event::SetForwardDirection
      if @garden.actors[event.actor_name]
        @garden.actors[event.actor_name].set_forward_direction(event.dir)

#        puts "Event::SetForwardDirection" if event.actor_name != @actor.name
      else
        puts "no actor_name"
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

  #
  # Ui event handlers
  #
  def key_pressed(keyEvent)
#    puts "key_pressed"

    if (keyEvent.key == UI::KC_ESCAPE)
      @event_router.quit = true
    elsif (keyEvent.key == UI::KC_E)
      event = Event::RequestEnableAction.new(@actor.name)
      event.forward = true
      @event_router.send_event(event)
#      @actor.move_forward(true)
    elsif (keyEvent.key == UI::KC_D)
      event = Event::RequestEnableAction.new(@actor.name)
      event.backward = true
      @event_router.send_event(event)
#      @actor.move_backward(true)
    elsif (keyEvent.key == UI::KC_S)
      event = Event::RequestEnableAction.new(@actor.name)
      event.left = true
      @event_router.send_event(event)
#      @actor.move_left(true)
    elsif (keyEvent.key == UI::KC_F)
      event = Event::RequestEnableAction.new(@actor.name)
      event.right = true
      @event_router.send_event(event)
#      @actor.move_right(true)
=begin
    elsif (keyEvent.key == UI::KC_R)
      @actor.press_gravity()
    elsif (keyEvent.key == UI::KC_V)
      @actor.stop_gravity()
=end
    elsif (keyEvent.key == UI::KC_SPACE)
      event = Event::RequestEnableAction.new(@actor.name)
      event.jump = true
      @event_router.send_event(event)
#      @actor.jump(true)
    end

    return true
  end

  def key_released(keyEvent)
    if (keyEvent.key == UI::KC_E)
      event = Event::RequestDisableAction.new(@actor.name)
      event.forward = true
      @event_router.send_event(event)
 #     @actor.move_forward(false)
    elsif (keyEvent.key == UI::KC_D)
      event = Event::RequestDisableAction.new(@actor.name)
      event.backward = true
      @event_router.send_event(event)
#      @actor.move_backward(false)
    elsif (keyEvent.key == UI::KC_S)
      event = Event::RequestDisableAction.new(@actor.name)
      event.left = true
      @event_router.send_event(event)
#      @actor.move_left(false)
    elsif (keyEvent.key == UI::KC_F)
      event = Event::RequestDisableAction.new(@actor.name)
      event.right = true
      @event_router.send_event(event)
#      @actor.move_right(false)
    elsif (keyEvent.key == UI::KC_SPACE)
      event = Event::RequestDisableAction.new(@actor.name)
      event.jump = true
      @event_router.send_event(event)
#      @actor.jump(false)
    end
    return true
  end

  def mouse_moved(evt)
    @camera_mover.mouse_moved(evt)
    return true
  end

  def mouse_pressed(mouseEvent, mouseButtonID)
=begin
    if (mouseButtonID == UI::MB_Left)
      @actor.action_left()
    elsif (mouseButtonID == UI::MB_Right)
      @actor.action_right()
    end
=end
    return true
  end

  def mouse_released(mouseEvent, mouseButtonID)
    return true
  end
end

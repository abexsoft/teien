require 'teien'
require_relative './user_event'
require_relative 'sinbad/sinbad'

include Teien

class ActorController
  def initialize(garden, ui)
    @garden = garden
    @garden.register_receiver(self)
    @ui = ui
    @ui.register_receiver(self)
    @quit = false

    @actor = nil

    @first_update = true
  end

  def setup(garden)
    @camera_mover = @ui.get_camera().get_mover()
    @camera_mover.set_position(Vector3D.new(0, 10, 0))
    @camera_mover.look_at(Vector3D.new(0, 0, 0))

    @ui.show_frame_stats(UI::TL_BOTTOMLEFT)
    @ui.show_logo(UI::TL_BOTTOMRIGHT)
    @ui.hide_cursor()
  end

  def update(delta)
    if @first_update
      event = Event::RequestControllable.new()
      @garden.send_event(event)
      @first_update = false
    end

    @camera_mover.update(delta)

    if @actor
      event = Event::SetForwardDirection.new(@actor.name, Vector3D.to_self(@camera_mover.camera.get_direction()))
      @garden.send_event(event)
#      @actor.set_forward_direction(event.dir) 
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

      @camera_mover.set_style(CameraMover::CS_TPS)
      @camera_mover.set_target(@actor.object)
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

  #
  # Ui event handlers
  #
  def key_pressed(keyEvent)
#    puts "key_pressed"

    if (keyEvent.key == UI::KC_ESCAPE)
      @garden.quit()
    elsif (keyEvent.key == UI::KC_E)
      event = Event::EnableAction.new(@actor.name)
      event.forward = true
      @garden.send_event(event)
#      @actor.move_forward(true)
    elsif (keyEvent.key == UI::KC_D)
      event = Event::EnableAction.new(@actor.name)
      event.backward = true
      @garden.send_event(event)
#      @actor.move_backward(true)
    elsif (keyEvent.key == UI::KC_S)
      event = Event::EnableAction.new(@actor.name)
      event.left = true
      @garden.send_event(event)
#      @actor.move_left(true)
    elsif (keyEvent.key == UI::KC_F)
      event = Event::EnableAction.new(@actor.name)
      event.right = true
      @garden.send_event(event)
#      @actor.move_right(true)
=begin
    elsif (keyEvent.key == UI::KC_R)
      @actor.press_gravity()
    elsif (keyEvent.key == UI::KC_V)
      @actor.stop_gravity()
=end
    elsif (keyEvent.key == UI::KC_SPACE)
      event = Event::EnableAction.new(@actor.name)
      event.jump = true
      @garden.send_event(event)
#      @actor.jump(true)
    end

    return true
  end

  def key_released(keyEvent)
    if (keyEvent.key == UI::KC_E)
      event = Event::DisableAction.new(@actor.name)
      event.forward = true
      @garden.send_event(event)
 #     @actor.move_forward(false)
    elsif (keyEvent.key == UI::KC_D)
      event = Event::DisableAction.new(@actor.name)
      event.backward = true
      @garden.send_event(event)
#      @actor.move_backward(false)
    elsif (keyEvent.key == UI::KC_S)
      event = Event::DisableAction.new(@actor.name)
      event.left = true
      @garden.send_event(event)
#      @actor.move_left(false)
    elsif (keyEvent.key == UI::KC_F)
      event = Event::DisableAction.new(@actor.name)
      event.right = true
      @garden.send_event(event)
#      @actor.move_right(false)
    elsif (keyEvent.key == UI::KC_SPACE)
      event = Event::DisableAction.new(@actor.name)
      event.jump = true
      @garden.send_event(event)
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

require_relative "../common/browser_event"

include Teien

class BrowserApplication < Teien::Application
  def initialize()
    super

    @ui = Teien::get_component("user_interface")
    @ui.register_receiver(self)
    @camera_mover = nil
  end

  ##
  # handlers of EventRouter.
  #

  def setup()
    puts "browser setup"
    @controllable_actor_name = nil

    @camera_mover = @ui.get_camera().get_mover()

    # REVISIT: There is a bug which set_position must set same parameters(x, y, z).
    @camera_mover.set_position(Vector3D.new(50, 50, 50))
    @camera_mover.look_at(Vector3D.new(0, 0, 0))

    @ui.show_frame_stats(UI::TL_BOTTOMLEFT)
    @ui.show_logo(UI::TL_BOTTOMRIGHT)
    @ui.hide_cursor()
  end

  def connection_completed(from)
    event = Teien::Event::Browser::ReadyToGo.new
    @event_router.send_event(event, from)
  end

  def update(delta)
    @camera_mover.update(delta)

    if @controllable_actor_name
      camera_dir = Vector3D.to_self(@camera_mover.camera.get_direction())
      event = Teien::Event::Actor::RequestSetForwardDirection.new(@controllable_actor_name, camera_dir)
      @event_router.send_event(event)
    end
  end

  def receive_event(event, from)
    case event
    when Teien::Event::Browser::ControllableActor
      @controllable_actor_name = event.actor_name

      actor = Teien::get_component("actor_manager").actors[@controllable_actor_name]
      @camera_mover.set_style(CameraMover::CS_TPS)
      @camera_mover.set_target(actor.object)
    end
  end

  ##
  # handlers of UserInterface.
  #

  def key_pressed(keyEvent)
    if (keyEvent.key == UI::KC_E)
      @camera_mover.move_forward(true)
      if @controllable_actor_name
        event = Teien::Event::Actor::RequestEnableAction.new(@controllable_actor_name)
        event.forward = true
        @event_router.send_event(event)
      end
    elsif (keyEvent.key == UI::KC_D)
      @camera_mover.move_backward(true)
      if @controllable_actor_name
        event = Teien::Event::Actor::RequestEnableAction.new(@controllable_actor_name)
        event.backward = true
        @event_router.send_event(event)
      end
    elsif (keyEvent.key == UI::KC_S)
      @camera_mover.move_left(true) 
      if @controllable_actor_name
        event = Teien::Event::Actor::RequestEnableAction.new(@controllable_actor_name)
        event.left = true
        @event_router.send_event(event)
      end
    elsif (keyEvent.key == UI::KC_F)
      @camera_mover.move_right(true)
      if @controllable_actor_name
        event = Teien::Event::Actor::RequestEnableAction.new(@controllable_actor_name)
        event.right = true
        @event_router.send_event(event)
      end
    elsif (keyEvent.key == UI::KC_SPACE)
      if @controllable_actor_name
        event = Teien::Event::Actor::RequestEnableAction.new(@controllable_actor_name)
        event.jump = true
        @event_router.send_event(event)
      end
    elsif (keyEvent.key == UI::KC_G)
      if @ui.debug_draw
        @ui.set_debug_draw(false)
      else
        @ui.set_debug_draw(true)
      end
    elsif (keyEvent.key == UI::KC_ESCAPE)
      @event_router.quit = true
    end

    event = Event::Browser::KeyPressed.new(keyEvent.key)
    @event_router.send_event(event)

    return true
  end

  def key_released(keyEvent)
    if (keyEvent.key == UI::KC_ESCAPE)
      @quit =true
    elsif (keyEvent.key == UI::KC_E)
      @camera_mover.move_forward(false)

      if @controllable_actor_name
        event = Teien::Event::Actor::RequestDisableAction.new(@controllable_actor_name)
        event.forward = true
        @event_router.send_event(event)
      end
    elsif (keyEvent.key == UI::KC_D)
      @camera_mover.move_backward(false)

      if @controllable_actor_name
        event = Teien::Event::Actor::RequestDisableAction.new(@controllable_actor_name)
        event.backward = true
        @event_router.send_event(event)
      end
    elsif (keyEvent.key == UI::KC_S)
      @camera_mover.move_left(false) 

      if @controllable_actor_name
        event = Teien::Event::Actor::RequestDisableAction.new(@controllable_actor_name)
        event.left = true
        @event_router.send_event(event)
      end
    elsif (keyEvent.key == UI::KC_F)
      @camera_mover.move_right(false) 
      if @controllable_actor_name
        event = Teien::Event::Actor::RequestDisableAction.new(@controllable_actor_name)
        event.right = true
        @event_router.send_event(event)
      end
    elsif (keyEvent.key == UI::KC_SPACE)
      if @controllable_actor_name
        event = Teien::Event::Actor::RequestDisableAction.new(@controllable_actor_name)
        event.jump = true
        @event_router.send_event(event)
      end
    end

    event = Event::Browser::KeyReleased.new(keyEvent.key)
    @event_router.send_event(event)

    return true
  end

  def mouse_moved(mouseEvent)
    @camera_mover.mouse_moved(mouseEvent)
    return true
  end

  def mouse_pressed(mouseEvent, mouseButtonID)
    @camera_mover.mouse_pressed(mouseEvent, mouseButtonID) 

    event = Event::Browser::MousePressed.new(mouseEvent, mouseButtonID, @ui.get_camera())
    @event_router.send_event(event)

    return true
  end

  def mouse_released(mouseEvent, mouseButtonID)
    @camera_mover.mouse_released(mouseEvent, mouseButtonID) 

    event = Event::Browser::MouseReleased.new(mouseEvent, mouseButtonID, @ui.get_camera())
    @event_router.send_event(event)

    return true
  end
end


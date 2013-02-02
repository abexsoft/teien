require_relative "browser_event"

module Teien

class Browser
  def initialize(event_router, base_object_manager, user_interface)
    @event_router = event_router
    @event_router.register_receiver(self)
    @base_object_manager = base_object_manager
    @ui = user_interface
    @ui.register_receiver(self)
  end

  def setup()
    @camera_mover = @ui.get_camera().get_mover()
    @camera_mover.set_position(Vector3D.new(0, 10, 0))
    @camera_mover.look_at(Vector3D.new(0, 0, 0))

    @ui.show_frame_stats(UI::TL_BOTTOMLEFT)
    @ui.show_logo(UI::TL_BOTTOMRIGHT)
    @ui.hide_cursor()
  end

  # handler of EventRouter.
  def receive_event(event, from)
  end
  
  # handlers of UserInterface.
  def key_pressed(keyEvent)
    event = Event::Browser::KeyPressed.new(keyEvent.key)
    @event_router.send_event(event)

    if (keyEvent.key == UI::KC_E)
      @camera_mover.move_forward(true)
    elsif (keyEvent.key == UI::KC_D)
      @camera_mover.move_backward(true)
    elsif (keyEvent.key == UI::KC_S)
      @camera_mover.move_left(true)
    elsif (keyEvent.key == UI::KC_F)
      @camera_mover.move_right(true)
    elsif (keyEvent.key == UI::KC_G)
      if @ui.debug_draw
        @ui.set_debug_draw(false)
      else
        @ui.set_debug_draw(true)
      end
    elsif (keyEvent.key == UI::KC_ESCAPE)
      @event_router.quit = true
    end
    return true
  end

  def key_released(keyEvent)
    event = Event::Browser::KeyReleased.new(keyEvent.key)
    @event_router.send_event(event)

    if (keyEvent.key == UI::KC_ESCAPE)
      @quit =true
    elsif (keyEvent.key == UI::KC_E)
      @camera_mover.move_forward(false)
    elsif (keyEvent.key == UI::KC_D)
      @camera_mover.move_backward(false)
    elsif (keyEvent.key == UI::KC_S)
      @camera_mover.move_left(false)
    elsif (keyEvent.key == UI::KC_F)
      @camera_mover.move_right(false)
    end
    return true
  end

  def mouse_moved(mouseEvent)
    @camera_mover.mouse_moved(mouseEvent)
    return true
  end

  def mouse_pressed(mouseEvent, mouseButtonID)
    @camera_mover.mouse_pressed(mouseEvent, mouseButtonID)
    return true
  end

  def mouse_released(mouseEvent, mouseButtonID)
    @camera_mover.mouse_released(mouseEvent, mouseButtonID)
    return true
  end
end

end

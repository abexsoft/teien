require_relative 'event'

module Ui
  def ui_setup()
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

  def ui_connection_completed(from)
    event = Teien::Event::ReadyToGo.new
    @event_router.send_event(event, from)
  end

  def ui_update(delta)
    @camera_mover.update(delta)
  end

  def ui_receive_event(event, from)
  end

  ##
  # UserInterface handlers 
  #

  def key_pressed(keyEvent)
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

    event = Event::KeyPressed.new(keyEvent.key)
    @event_router.send_event(event)

    return true
  end

  def key_released(keyEvent)
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

    event = Event::KeyReleased.new(keyEvent.key)
    @event_router.send_event(event)

    return true
  end

  def mouse_moved(mouseEvent)
    @camera_mover.mouse_moved(mouseEvent)
    return true
  end

  def mouse_pressed(mouseEvent, mouseButtonID)
    @camera_mover.mouse_pressed(mouseEvent, mouseButtonID) 

    event = Event::MousePressed.new(mouseEvent, mouseButtonID, @ui.get_camera())
    @event_router.send_event(event)

    return true
  end

  def mouse_released(mouseEvent, mouseButtonID)
    @camera_mover.mouse_released(mouseEvent, mouseButtonID) 

    event = Event::MouseReleased.new(mouseEvent, mouseButtonID, @ui.get_camera())
    @event_router.send_event(event)

    return true
  end
end

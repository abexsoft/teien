require 'teien'

include Teien

class HelloGardenController
  def initialize(garden)
    @garden = garden

    @garden.set_window_title("SimpleGarden")

    @quit = false

    # set config files.
    fileDir = File.dirname(File.expand_path(__FILE__))
    @garden.plugins_cfg = "#{fileDir}/plugins.cfg"
    @garden.resources_cfg = "#{fileDir}/resources.cfg"
  end

  def setup()
    @garden.event_router.register_receiver(Event::KeyPressed, self)
    @garden.event_router.register_receiver(Event::KeyReleased, self)
    @garden.event_router.register_receiver(Event::MouseMoved, self)

    @camera_mover = @garden.ui.get_camera().get_mover()
#    @camera_mover.set_style(CameraMover::CS_TPS)
#    @camera_mover.set_target(floor)
#    @camera_mover.set_yaw_pitch_dist(Radian.new(Degree.new(0)), Radian.new(Degree.new(45)), 30.0)

    @camera_mover.set_position(Vector3D.new(50, 50, 50))
    @camera_mover.look_at(Vector3D.new(0, 0, 0))


    @garden.ui.show_frame_stats(UI::TL_BOTTOMLEFT)
    @garden.ui.show_logo(UI::TL_BOTTOMRIGHT)
    @garden.ui.hide_cursor()

  end

  def update(delta)
    @camera_mover.update(delta)
    return !@quit
  end

  def receive_event(event)
    case event
    when Event::KeyPressed
      if (event.key == UI::KC_E)
        @camera_mover.move_forward(true)
      elsif (event.key == UI::KC_D)
        @camera_mover.move_backward(true)
      elsif (event.key == UI::KC_S)
        @camera_mover.move_left(true)
      elsif (event.key == UI::KC_F)
        @camera_mover.move_right(true)
      elsif (event.key == UI::KC_ESCAPE)
        @quit = true
      end
    when Event::KeyReleased
      if (event.key == UI::KC_E)
        @camera_mover.move_forward(false)
      elsif (event.key == UI::KC_D)
        @camera_mover.move_backward(false)
      elsif (event.key == UI::KC_S)
        @camera_mover.move_left(false)
      elsif (event.key == UI::KC_F)
        @camera_mover.move_right(false)
      end
    when Event::MouseMoved
      @camera_mover.mouse_moved(event.event)
    when Event::MousePressed
      @camera_mover.mouse_pressed(event.event, event.button_id)
    when Event::MouseReleased
      @camera_mover.mouse_released(event.event, event.button_id)
    end

    return true
  end
end

garden = create_proxy_garden(HelloGardenController)
garden.run()

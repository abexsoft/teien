require 'teien'
require_relative './user_event'

include Teien

class HelloGardenController
  def initialize(garden, ui)
    @garden = garden
    @garden.register_receiver(self)
    @ui = ui
    @ui.register_receiver(self)
    @quit = false
  end

  # called as a receiver by a dispatcher.

  # By UserInterface

  def setup(garden)
    puts "controller setup"
    @ui.set_window_title("SimpleGarden")

    # set config files.
    fileDir = File.dirname(File.expand_path(__FILE__))
    @garden.plugins_cfg = "#{fileDir}/plugins.cfg"
    @garden.resources_cfg = "#{fileDir}/resources.cfg"

    @camera_mover = @ui.get_camera().get_mover()
#    @camera_mover.set_style(CameraMover::CS_TPS)
#    @camera_mover.set_target(floor)
#    @camera_mover.set_yaw_pitch_dist(Radian.new(Degree.new(0)), Radian.new(Degree.new(45)), 30.0)

    @camera_mover.set_position(Vector3D.new(50, 50, 50))
    @camera_mover.look_at(Vector3D.new(0, 0, 0))

    @ui.show_frame_stats(UI::TL_BOTTOMLEFT)
    @ui.show_logo(UI::TL_BOTTOMRIGHT)
    @ui.hide_cursor()
  end

  def update(delta)
    @camera_mover.update(delta)
    return !@quit
  end

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
      @garden.quit()
    end
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
    return true
  end

  def mouse_moved(mouseEvent)
    @camera_mover.mouse_moved(mouseEvent)
    return true
  end

  def mouse_pressed(mouseEvent, mouseButtonID)
    @camera_mover.mouse_pressed(mouseEvent, mouseButtonID)
    event = Event::ShotBox.new(@ui.get_camera().get_position(), 
                               @ui.get_camera().get_direction())
    @garden.send_event(event)
    return true
  end

  def mouse_released(mouseEvent, mouseButtonID)
    @camera_mover.mouse_released(mouseEvent, mouseButtonID)
    return true
  end
end


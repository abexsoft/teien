module Teien

class CameraMover
  CS_FREELOOK = 0
  CS_ORBIT = 1
  CS_MANUAL = 2
  CS_TPS = 3

  CAM_HEIGHT = 5.0

  attr_accessor :height
  attr_accessor :camera_pivot
  attr_accessor :camera

  def initialize(cam)
    @camera = cam
    @camera.set_position(0, 0, 0)
    @camera.set_near_clip_distance(0.1)

    # CS_FREELOOK, CS_ORBIT, CS_MANUAL
    @sdk_camera_man = Ogrebites::SdkCameraMan.new(@camera)
    @evt_frame = Ogre::FrameEvent.new

    # CS_TPS
    @height = CAM_HEIGHT
    @camera_pivot = cam.get_scene_manager().get_root_scene_node().create_child_scene_node()
    @camera_goal = @camera_pivot.create_child_scene_node(Ogre::Vector3.new(0, 0, 5))

    @camera_pivot.set_fixed_yaw_axis(true)
    @camera_goal.set_fixed_yaw_axis(true)

    @pivot_pitch = 0

    set_style(CS_FREELOOK)
  end

  def set_style(style)
    @style = style
    case @style
    when CS_FREELOOK
      @sdk_camera_man.set_style(Ogrebites::CS_FREELOOK)
    when CS_ORBIT
      @sdk_camera_man.set_style(Ogrebites::CS_ORBIT)
    else  # CS_MANUAL, CS_TPS
      @sdk_camera_man.set_style(Ogrebites::CS_MANUAL)
    end
  end

  def set_target(target)
    @target = target
    if @style == CS_TPS
      @camera.set_auto_tracking(false)
      @camera.move_relative(Ogre::Vector3.new(0, 0, 0))
      update_camera(1.0)
    else
      @sdk_camera_man.set_target(target.pivotSceneNode)
    end
  end

  def set_position(pos)
    @camera.set_position(Vector3D.to_ogre(pos)) if @style == CS_FREELOOK
  end

  def look_at(pos)
    @camera.look_at(Vector3D.to_ogre(pos)) if @style == CS_FREELOOK
  end

  def set_yaw_pitch_dist(yaw, pitch, dist)
    @sdk_camera_man.setYawPitchDist(yaw, pitch, dist) if @style == CS_ORBIT
  end

  def move_forward(bl)
    evt = Ois::KeyEvent.new(nil, Ois::KC_W, 0)
    if bl
      @sdk_camera_man.inject_key_down(evt)
    else
      @sdk_camera_man.inject_key_up(evt)
    end
  end

  def move_backward(bl)
    evt = Ois::KeyEvent.new(nil, Ois::KC_S, 0)
    if bl
      @sdk_camera_man.inject_key_down(evt)
    else
      @sdk_camera_man.inject_key_up(evt)
    end
  end

  def move_left(bl)
    evt = Ois::KeyEvent.new(nil, Ois::KC_A, 0)
    if bl
      @sdk_camera_man.inject_key_down(evt)
    else
      @sdk_camera_man.inject_key_up(evt)
    end
  end

  def move_right(bl)
    evt = Ois::KeyEvent.new(nil, Ois::KC_D, 0)
    if bl
      @sdk_camera_man.inject_key_down(evt)
    else
      @sdk_camera_man.inject_key_up(evt)
    end
  end


  def update(delta)
    if (@style == CS_TPS)
      update_camera(delta)
    else
      @evt_frame.timeSinceLastFrame = delta
      @sdk_camera_man.frame_rendering_queued(@evt_frame)
    end
  end

  #
  # This method moves this camera position to the goal position smoothly.
  # In general, should be called in the frameRenderingQueued handler.
  #
  def update_camera(deltaTime)
    # place the camera pivot roughly at the character's shoulder
    @camera_pivot.set_position(Vector3D::to_ogre(@target.get_position()) + Ogre::Vector3.UNIT_Y * @height)
    # move the camera smoothly to the goal
    goalOffset = @camera_goal._get_derived_position() - @camera.get_position()
    @camera.move(goalOffset * deltaTime * 9.0)
    # always look at the pivot
    @camera.look_at(@camera_pivot._get_derived_position())
  end

  def mouse_moved(evt)
#    puts "#{evt.state.X.rel}, #{evt.state.X.abs}"
#    puts "#{evt.state.Y.rel}, #{evt.state.Y.abs}"
#    puts ""

    # deal with a warp.
    if evt.state.X.rel.abs > 300
      return true
    end

    if @style == CS_TPS
      update_camera_goal(-0.05 * evt.state.X.rel, 
                         -0.05 * evt.state.Y.rel, 
                         -0.0005 * evt.state.Z.rel)
    else
      @sdk_camera_man.inject_mouse_move(evt)      
    end    
    return true
  end

  #
  # This method updates the goal position, which this camera should be placed finally.
  # In general, should be called when the mouse is moved.
  # *deltaYaw*::_float_, degree value.
  # *deltaPitch*::_float_, degree value.
  # *deltaZoom*::_float_, zoom 
  #
  def update_camera_goal(deltaYaw, deltaPitch, deltaZoom)

    @camera_pivot.yaw(Ogre::Radian.new(Ogre::Degree.new(deltaYaw)), Ogre::Node::TS_WORLD);

    # bound the pitch
    if (!(@pivot_pitch + deltaPitch > 25 && deltaPitch > 0) &&
        !(@pivot_pitch + deltaPitch < -60 && deltaPitch < 0))
      @camera_pivot.pitch(Ogre::Radian.new(Ogre::Degree.new(deltaPitch)), Ogre::Node::TS_LOCAL)
      @pivot_pitch += deltaPitch;
    end
    dist = @camera_goal._get_derived_position().distance(@camera_pivot._get_derived_position())
    distChange = deltaZoom * dist;

#    puts "dist: #{dist}:#{distChange}"

    # bound the zoom
    if (!(dist + distChange < 8 && distChange < 0) &&
        !(dist + distChange > 25 && distChange > 0))

      @camera_goal.translate(Ogre::Vector3.new(0, 0, distChange), Ogre::Node::TS_LOCAL)
    end
  end

  def mouse_pressed(mouseEvent, mouseButtonID)
    @sdk_camera_man.inject_mouse_down(mouseEvent, mouseButtonID) if @style == CS_ORBIT
    return true
  end

  def mouse_released(mouseEvent, mouseButtonID)
    @sdk_camera_man.inject_mouse_up(mouseEvent, mouseButtonID) if @style == CS_ORBIT
    return true
  end
  
end

end

require 'teien'

include Teien

class HelloGarden
  attr_accessor :info

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
    @ui = @garden.create_user_interface()

    @garden.set_ambient_light(Color.new(0.1, 0.1, 0.1))
    @garden.set_sky_dome(true, "Examples/CloudySky", 5, 8)
    @garden.set_gravity(Vector3D.new(0.0, -9.8, 0.0))

    @light = @garden.create_light("directionalLight")
    @light.set_type(LightObject::DIRECTIONAL)
    @light.set_diffuse_color(Color.new(1.0, 1.0, 1.0))
    @light.set_specular_color(Color.new(0.25, 0.25, 0))
    @light.set_direction(Vector3D.new( -1, -1, -1 ))

    # create a floor.
    object_info = FloorObjectInfo.new(50, 50, 0.5, 1, 1, 5, 5)
    object_info.material_name = "Examples/Rockwall"
    floor = @garden.create_object("Floor", object_info, PhysicsInfo.new(0))
    floor.set_position(Vector3D.new(0, 0, 0))

    # create a box.
    object_info = BoxObjectInfo.new(Vector3D.new(1, 1, 1))
    object_info.material_name = "Examples/BumpyMetal"
    box = @garden.create_object("boxTest", object_info, PhysicsInfo.new(10))
    box.set_position(Vector3D.new(0, 1.0, 0))

    # create a sphere
    object_info = SphereObjectInfo.new(1.0)
    object_info.material_name = "Examples/SphereMappedRustySteel"
    sphere = @garden.create_object("sphere", object_info, PhysicsInfo.new(10))
    sphere.set_position(Vector3D.new(0, 1.0, -2))

    # create a capsule
    object_info = CapsuleObjectInfo.new(1.0, 2.0)
    object_info.material_name = "Examples/RustySteel"
    capsule = @garden.create_object("capsule", object_info, PhysicsInfo.new(10))
    capsule.set_position(Vector3D.new(1, 5, 1))

    # create a cone
    object_info = ConeObjectInfo.new(1.0, 2.0)
    object_info.material_name = "Examples/BeachStones"
    cone = @garden.create_object("cone", object_info, PhysicsInfo.new(10))
    cone.set_position(Vector3D.new(1, 10, 1))

    # create a cylinder
    object_info = CylinderObjectInfo.new(1.0, 2.0)
    object_info.material_name = "Examples/BumpyMetal"
    cylinder = @garden.create_object("cylinder", object_info, PhysicsInfo.new(10))
    cylinder.set_position(Vector3D.new(-1, 10, -1))

    # create a meshBB object
    object_info = MeshBBObjectInfo.new("penguin.mesh", Vector3D.new(1.0, 1.0, 1.0))
    object_info.scale = Vector3D.new(1.0 / 20.0, 1.0 / 20.0, 1.0 / 20.0)
    object_info.physics_offset = Vector3D.new(0, 1.0, 0)
    object_info.view_offset = Vector3D.new(0, 1.2, 0)
    pen = @garden.create_object("pen", object_info, PhysicsInfo.new(10))
    pen.set_position(Vector3D.new(1, 15, 0))

    # create a mesh object
    object_info = MeshObjectInfo.new("penguin.mesh")
    object_info.scale = Vector3D.new(1.0 / 20.0, 1.0 / 20.0, 1.0 / 20.0)
    pen = @garden.create_object("penpen", object_info, PhysicsInfo.new(10))
    pen.set_position(Vector3D.new(1, 20, 0))

    @ui.set_controller(self)

    @camera_mover = @ui.get_camera().get_mover()
#    @camera_mover.set_style(CameraMover::CS_FREELOOK)
#    @camera_mover.set_style(CameraMover::CS_ORBIT)
    @camera_mover.set_style(CameraMover::CS_TPS)
    @camera_mover.set_target(floor)
    @camera_mover.set_yaw_pitch_dist(Radian.new(Degree.new(0)), Radian.new(Degree.new(45)), 30.0)
#    @camera_mover.set_position(Vector3D.new(20, 20, 20))
#    @camera_mover.look_at(Vector3D.new(0, 0, 0))

    @ui.show_frame_stats(UI::TL_BOTTOMLEFT)
    @ui.show_logo(UI::TL_BOTTOMRIGHT)
    @ui.hide_cursor()
  end

  def update(delta)
#    print "Garden tick is called: ", evt.timeSinceLastFrame * 1000, "\n"
    return false if (@quit) # end of mainloop

    @camera_mover.update(delta)
    
    return true
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
    return true
  end

  def mouse_released(mouseEvent, mouseButtonID)
    @camera_mover.mouse_released(mouseEvent, mouseButtonID)
    return true
  end
end


garden = create_garden(HelloGarden)
garden.run()

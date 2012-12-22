require 'teien'

include Teien

class BulletRagdoll
  M_PI = 3.14159265358979323846
  M_PI_2 = 1.57079632679489661923
  M_PI_4 = 0.785398163397448309616

  CONSTRAINT_DEBUG_SIZE = 0.2

  BODYPART_PELVIS = 0
  BODYPART_SPINE = 1
  BODYPART_HEAD = 2
  BODYPART_LEFT_UPPER_LEG = 3
  BODYPART_LEFT_LOWER_LEG = 4
  BODYPART_RIGHT_UPPER_LEG = 5
  BODYPART_RIGHT_LOWER_LEG = 6
  BODYPART_LEFT_UPPER_ARM = 7
  BODYPART_LEFT_LOWER_ARM = 8
  BODYPART_RIGHT_UPPER_ARM = 9
  BODYPART_RIGHT_LOWER_ARM = 10
  BODYPART_COUNT = 11

  JOINT_PELVIS_SPINE = 0
  JOINT_SPINE_HEAD = 1
  JOINT_LEFT_HIP = 2
  JOINT_LEFT_KNEE = 3
  JOINT_RIGHT_HIP = 4
  JOINT_RIGHT_KNEE = 5
  JOINT_LEFT_SHOULDER = 6
  JOINT_LEFT_ELBOW = 7
  JOINT_RIGHT_SHOULDER = 8
  JOINT_RIGHT_ELBOW = 9
  JOINT_COUNT = 10

  def initialize(garden)
    @garden = garden

    @evt = Ogre::FrameEvent.new
    @cap_num = 0
    @objs = []
    @quit = false

    # set config files.
    fileDir = File.dirname(File.expand_path(__FILE__))
    @garden.plugins_cfg = "#{fileDir}/plugins.cfg"
    @garden.resources_cfg = "#{fileDir}/resources.cfg"

    @shot_num = 0
  end

  def setup()
    @garden.set_ambient_light(Color.new(0.1, 0.1, 0.1))
    @garden.set_sky_dome(true, "Examples/CloudySky", 5, 8)
    @garden.set_gravity(Vector3D.new(0.0, -9.8, 0.0))
    @light = @garden.create_light("directionalLight");
    @light.set_type(LightObject::DIRECTIONAL);
    @light.set_diffuse_color(Color.new(1.0, 1.0, 1.0));
    @light.set_specular_color(Color.new(0.25, 0.25, 0));
    @light.set_direction(Vector3D.new( -1, -1, -1 ));

    # create floor
    object_info = FloorObjectInfo.new(50, 50, 0.5, 1, 1, 5, 5)
    object_info.material_name = "Examples/Rockwall"
    floor = @garden.create_object("Floor", object_info, PhysicsInfo.new(0))
    floor.set_position(Vector3D.new(0, 0, 0))    

    setup_body(Bullet::BtVector3.new(1.0, 1.0, 0.0))

    @ui = @garden.create_user_interface()
    @ui.set_controller(self)

    @camera_mover = @ui.get_camera().get_mover()
    @camera_mover.set_position(Vector3D.new(5, 5, 5))
    @camera_mover.look_at(Vector3D.new(0, 0, 0))

    @ui.show_frame_stats(UI::TL_BOTTOMLEFT)
    @ui.show_logo(UI::TL_BOTTOMRIGHT)
    @ui.hide_cursor()
  end

  def setup_body(positionOffset)
    @shapes = []
    @shapes[BODYPART_PELVIS] = Bullet::BtCapsuleShape.new(0.15, 0.20)
    @shapes[BODYPART_SPINE] = Bullet::BtCapsuleShape.new(0.15, 0.28)
    @shapes[BODYPART_HEAD] = Bullet::BtCapsuleShape.new(0.10, 0.05)
    @shapes[BODYPART_LEFT_UPPER_LEG] = Bullet::BtCapsuleShape.new(0.07, 0.45)
    @shapes[BODYPART_LEFT_LOWER_LEG] = Bullet::BtCapsuleShape.new(0.05, 0.37)
    @shapes[BODYPART_RIGHT_UPPER_LEG] = Bullet::BtCapsuleShape.new(0.07, 0.45)
    @shapes[BODYPART_RIGHT_LOWER_LEG] = Bullet::BtCapsuleShape.new(0.05, 0.37)
    @shapes[BODYPART_LEFT_UPPER_ARM] = Bullet::BtCapsuleShape.new(0.05, 0.33)
    @shapes[BODYPART_LEFT_LOWER_ARM] = Bullet::BtCapsuleShape.new(0.04, 0.25)
    @shapes[BODYPART_RIGHT_UPPER_ARM] = Bullet::BtCapsuleShape.new(0.05, 0.33)
    @shapes[BODYPART_RIGHT_LOWER_ARM] = Bullet::BtCapsuleShape.new(0.04, 0.25)

    # Setup all the rigid bodies
    offset = Bullet::BtTransform.new
    offset.set_identity()
    offset.set_origin(positionOffset)
    @bodies = []

    transform = Bullet::BtTransform.new
    transform.set_identity()
    transform.set_origin(Bullet::BtVector3.new(0.0, 1.0, 0.0))
    @bodies[BODYPART_PELVIS] = local_create_rigid_body(1.0, offset * transform, @shapes[BODYPART_PELVIS])

    transform.set_identity()
    transform.set_origin(Bullet::BtVector3.new(0.0, 1.2,0.0))
    @bodies[BODYPART_SPINE] = local_create_rigid_body(1.0, offset * transform, @shapes[BODYPART_SPINE])

    transform.set_identity()
    transform.set_origin(Bullet::BtVector3.new(0.0, 1.6, 0.0))
    @bodies[BODYPART_HEAD] = local_create_rigid_body(1.0, offset * transform, @shapes[BODYPART_HEAD])

    transform.set_identity()
    transform.set_origin(Bullet::BtVector3.new(-0.18, 0.65, 0.0))
    @bodies[BODYPART_LEFT_UPPER_LEG] = local_create_rigid_body(1.0, offset * transform, 
                                                            @shapes[BODYPART_LEFT_UPPER_LEG])

    transform.set_identity()
    transform.set_origin(Bullet::BtVector3.new(-0.18, 0.2, 0.0))
    @bodies[BODYPART_LEFT_LOWER_LEG] = local_create_rigid_body(1.0, offset * transform, 
                                                            @shapes[BODYPART_LEFT_LOWER_LEG])

    transform.set_identity()
    transform.set_origin(Bullet::BtVector3.new(0.18, 0.65, 0.0))
    @bodies[BODYPART_RIGHT_UPPER_LEG] = local_create_rigid_body(1.0, offset * transform, 
                                                             @shapes[BODYPART_RIGHT_UPPER_LEG])

    transform.set_identity()
    transform.set_origin(Bullet::BtVector3.new(0.18, 0.2, 0.0))
    @bodies[BODYPART_RIGHT_LOWER_LEG] = local_create_rigid_body(1.0, offset * transform, 
                                                             @shapes[BODYPART_RIGHT_LOWER_LEG])

    transform.set_identity()
    transform.set_origin(Bullet::BtVector3.new(-0.35, 1.45, 0.0))
    transform.get_basis().set_euler_zyx(0,0, M_PI_2)
    @bodies[BODYPART_LEFT_UPPER_ARM] = local_create_rigid_body(1.0, offset * transform, 
                                                            @shapes[BODYPART_LEFT_UPPER_ARM])

    transform.set_identity()
    transform.set_origin(Bullet::BtVector3.new(-0.7, 1.45, 0.0))
    transform.get_basis().set_euler_zyx(0,0,M_PI_2)
    @bodies[BODYPART_LEFT_LOWER_ARM] = local_create_rigid_body(1.0, offset * transform, 
                                                            @shapes[BODYPART_LEFT_LOWER_ARM])

    transform.set_identity()
    transform.set_origin(Bullet::BtVector3.new(0.35, 1.45, 0.0))
    transform.get_basis().set_euler_zyx(0,0,-M_PI_2)
    @bodies[BODYPART_RIGHT_UPPER_ARM] = local_create_rigid_body(1.0, offset*transform, 
                                                             @shapes[BODYPART_RIGHT_UPPER_ARM])

    transform.set_identity()
    transform.set_origin(Bullet::BtVector3.new(0.7, 1.45, 0.0))
    transform.get_basis().set_euler_zyx(0,0,-M_PI_2)
    @bodies[BODYPART_RIGHT_LOWER_ARM] = local_create_rigid_body(1.0, offset*transform, 
                                                             @shapes[BODYPART_RIGHT_LOWER_ARM])
    # Setup some damping on the m_bodies
    BODYPART_COUNT.times {|i|
      @bodies[i].set_damping(0.05, 0.85)
      @bodies[i].set_deactivation_time(0.8)
      @bodies[i].set_sleeping_thresholds(1.6, 2.5)
    }

    # Now setup the constraints
    localA = Bullet::BtTransform.new()
    localB = Bullet::BtTransform.new()
    @joints = []

    localA.set_identity()
    localB.set_identity()
    localA.get_basis().set_euler_zyx(0,M_PI_2,0)
    localA.set_origin(Bullet::BtVector3.new(0.0, 0.15, 0.0))
    localB.get_basis().set_euler_zyx(0,M_PI_2,0)
    localB.set_origin(Bullet::BtVector3.new(0.0, -0.15, 0.0))
    hingeC = Bullet::BtHingeConstraint.new(@bodies[BODYPART_PELVIS], @bodies[BODYPART_SPINE], 
                                           localA, localB)
    hingeC.set_limit(-M_PI_4, M_PI_2)
    @joints[JOINT_PELVIS_SPINE] = hingeC
    hingeC.set_dbg_draw_size(CONSTRAINT_DEBUG_SIZE)
    @garden.physics.dynamics_world.add_constraint(@joints[JOINT_PELVIS_SPINE], true)

    localA.set_identity()
    localB.set_identity();
    localA.get_basis().set_euler_zyx(0,0,M_PI_2)
    localA.set_origin(Bullet::BtVector3.new(0.0, 0.30, 0.0))
    localB.get_basis().set_euler_zyx(0,0,M_PI_2)
    localB.set_origin(Bullet::BtVector3.new(0.0, -0.14, 0.0))
    coneC = Bullet::BtConeTwistConstraint.new(@bodies[BODYPART_SPINE], @bodies[BODYPART_HEAD], 
                                              localA, localB)
    coneC.set_limit(M_PI_4, M_PI_4, M_PI_2)
    @joints[JOINT_SPINE_HEAD] = coneC
    coneC.set_dbg_draw_size(CONSTRAINT_DEBUG_SIZE)
    @garden.physics.dynamics_world.add_constraint(@joints[JOINT_SPINE_HEAD], true)

    localA.set_identity()
    localB.set_identity()
    # issue a NaN exception.
    # localA.get_basis().set_euler_zyx(0,0,-M_PI_4 * 5.0)
    localA.get_basis().set_euler_zyx(0,0,-M_PI_4)
    localA.set_origin(Bullet::BtVector3.new(-0.18, -0.10, 0.0))
    # issue a NaN exception.
    # localB.get_basis().set_euler_zyx(0,0,-M_PI_4 * 5.0)
    localB.get_basis().set_euler_zyx(0,0,-M_PI_4)
    localB.set_origin(Bullet::BtVector3.new(0.0, 0.225, 0.0))
    coneC = Bullet::BtConeTwistConstraint.new(@bodies[BODYPART_PELVIS], 
                                              @bodies[BODYPART_LEFT_UPPER_LEG], 
                                              localA, localB)
    coneC.set_limit(M_PI_4, M_PI_4, 0.0)
    @joints[JOINT_LEFT_HIP] = coneC
    coneC.set_dbg_draw_size(CONSTRAINT_DEBUG_SIZE)
    @garden.physics.dynamics_world.add_constraint(@joints[JOINT_LEFT_HIP], true);

    localA.set_identity()
    localB.set_identity();
    localA.get_basis().set_euler_zyx(0,M_PI_2,0); 
    localA.set_origin(Bullet::BtVector3.new((0.0), (-0.225), (0.0)));
    localB.get_basis().set_euler_zyx(0,M_PI_2,0); 
    localB.set_origin(Bullet::BtVector3.new((0.0), (0.185), (0.0)));
    hingeC = Bullet::BtHingeConstraint.new(@bodies[BODYPART_LEFT_UPPER_LEG], 
                                           @bodies[BODYPART_LEFT_LOWER_LEG], 
                                           localA, localB);
    hingeC.set_limit(0, M_PI_2)
    @joints[JOINT_LEFT_KNEE] = hingeC
    hingeC.set_dbg_draw_size(CONSTRAINT_DEBUG_SIZE)
    @garden.physics.dynamics_world.add_constraint(@joints[JOINT_LEFT_KNEE], true);

    localA.set_identity()
    localB.set_identity()
    localA.get_basis().set_euler_zyx(0,0,M_PI_4)
    localA.set_origin(Bullet::BtVector3.new((0.18), (-0.10), (0.0)))
    localB.get_basis().set_euler_zyx(0,0,M_PI_4)
    localB.set_origin(Bullet::BtVector3.new((0.0), (0.225), (0.0)))
    coneC = Bullet::BtConeTwistConstraint.new(@bodies[BODYPART_PELVIS], 
                                              @bodies[BODYPART_RIGHT_UPPER_LEG], 
                                              localA, localB);
    coneC.set_limit(M_PI_4, M_PI_4, 0)
    @joints[JOINT_RIGHT_HIP] = coneC
    coneC.set_dbg_draw_size(CONSTRAINT_DEBUG_SIZE)
    @garden.physics.dynamics_world.add_constraint(@joints[JOINT_RIGHT_HIP], true);

    localA.set_identity()
    localB.set_identity()
    localA.get_basis().set_euler_zyx(0,M_PI_2,0)
    localA.set_origin(Bullet::BtVector3.new((0.0), (-0.225), (0.0)));
    localB.get_basis().set_euler_zyx(0,M_PI_2,0)
    localB.set_origin(Bullet::BtVector3.new((0.0), (0.185), (0.0)));
    hingeC = Bullet::BtHingeConstraint.new(@bodies[BODYPART_RIGHT_UPPER_LEG], 
                                           @bodies[BODYPART_RIGHT_LOWER_LEG], 
                                           localA, localB)
    hingeC.set_limit((0), (M_PI_2))
    @joints[JOINT_RIGHT_KNEE] = hingeC
    hingeC.set_dbg_draw_size(CONSTRAINT_DEBUG_SIZE);
    @garden.physics.dynamics_world.add_constraint(@joints[JOINT_RIGHT_KNEE], true);

    localA.set_identity()
    localB.set_identity()
    localA.get_basis().set_euler_zyx(0,0,M_PI)
    localA.set_origin(Bullet::BtVector3.new((-0.2), (0.15), (0.0)))
    localB.get_basis().set_euler_zyx(0,0,M_PI_2)
    localB.set_origin(Bullet::BtVector3.new((0.0), (-0.18), (0.0)))
    coneC = Bullet::BtConeTwistConstraint.new(@bodies[BODYPART_SPINE], 
                                              @bodies[BODYPART_LEFT_UPPER_ARM], 
                                              localA, localB)
    coneC.set_limit(M_PI_2, M_PI_2, 0)
    @joints[JOINT_LEFT_SHOULDER] = coneC
    coneC.set_dbg_draw_size(CONSTRAINT_DEBUG_SIZE)
    @garden.physics.dynamics_world.add_constraint(@joints[JOINT_LEFT_SHOULDER], true);

    localA.set_identity()
    localB.set_identity()
    localA.get_basis().set_euler_zyx(0,M_PI_2,0)
    localA.set_origin(Bullet::BtVector3.new((0.0), (0.18), (0.0)))
    localB.get_basis().set_euler_zyx(0,M_PI_2,0)
    localB.set_origin(Bullet::BtVector3.new((0.0), (-0.14), (0.0)))
    hingeC = Bullet::BtHingeConstraint.new(@bodies[BODYPART_LEFT_UPPER_ARM], 
                                           @bodies[BODYPART_LEFT_LOWER_ARM], 
                                           localA, localB);
    hingeC.set_limit((0), (M_PI_2))
    @joints[JOINT_LEFT_ELBOW] = hingeC
    hingeC.set_dbg_draw_size(CONSTRAINT_DEBUG_SIZE)
    @garden.physics.dynamics_world.add_constraint(@joints[JOINT_LEFT_ELBOW], true)

    localA.set_identity()
    localB.set_identity()
    localA.get_basis().set_euler_zyx(0,0,0)
    localA.set_origin(Bullet::BtVector3.new((0.2), (0.15), (0.0)))
    localB.get_basis().set_euler_zyx(0,0,M_PI_2)
    localB.set_origin(Bullet::BtVector3.new((0.0), (-0.18), (0.0)))
    coneC = Bullet::BtConeTwistConstraint.new(@bodies[BODYPART_SPINE], 
                                              @bodies[BODYPART_RIGHT_UPPER_ARM], 
                                              localA, localB)
    coneC.set_limit(M_PI_2, M_PI_2, 0)
    @joints[JOINT_RIGHT_SHOULDER] = coneC
    coneC.set_dbg_draw_size(CONSTRAINT_DEBUG_SIZE)
    @garden.physics.dynamics_world.add_constraint(@joints[JOINT_RIGHT_SHOULDER], true);

    localA.set_identity()
    localB.set_identity()
    localA.get_basis().set_euler_zyx(0,M_PI_2,0)
    localA.set_origin(Bullet::BtVector3.new((0.0), (0.18), (0.0)))
    localB.get_basis().set_euler_zyx(0,M_PI_2,0)
    localB.set_origin(Bullet::BtVector3.new((0.0), (-0.14), (0.0)))
    hingeC = Bullet::BtHingeConstraint.new(@bodies[BODYPART_RIGHT_UPPER_ARM], 
                                           @bodies[BODYPART_RIGHT_LOWER_ARM], 
                                           localA, localB)
    hingeC.set_limit((0), (M_PI_2))
    @joints[JOINT_RIGHT_ELBOW] = hingeC
    hingeC.set_dbg_draw_size(CONSTRAINT_DEBUG_SIZE)
    @garden.physics.dynamics_world.add_constraint(@joints[JOINT_RIGHT_ELBOW], true)
  end

  def local_create_rigid_body(mass, startTransform, shape)
    name = "Capsule#{@cap_num}"
    @cap_num += 1

    object_info = CapsuleObjectInfo.new(shape.get_radius(), shape.get_half_height())
    object_info.material_name = "Examples/RustySteel"
    obj = @garden.create_object(name, object_info, PhysicsInfo.new(mass))
    obj.rigid_body.set_center_of_mass_transform(startTransform)

    @objs.push(obj)

    return obj.rigid_body
  end

  def update(delta)
    @camera_mover.update(delta)
    return !@quit
  end

  def key_pressed(keyEvent)
    case keyEvent.key
    when Ois::KC_ESCAPE
      @quit = true
    when Ois::KC_E
      @camera_mover.move_forward(true)
    when Ois::KC_D
      @camera_mover.move_backward(true)
    when Ois::KC_S
      @camera_mover.move_left(true)
    when Ois::KC_F
      @camera_mover.move_right(true)
    end
    return true
  end

  def key_released(keyEvent)
    case keyEvent.key
    when Ois::KC_E
      @camera_mover.move_forward(false)
    when Ois::KC_D
      @camera_mover.move_backward(false)
    when Ois::KC_S
      @camera_mover.move_left(false)
    when Ois::KC_F
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
    if (mouseButtonID == Ois::MB_Left)
      shot_sphere()
    end
    return true
  end

  def mouse_released(mouseEvent, mouseButtonID)
    @camera_mover.mouse_released(mouseEvent, mouseButtonID)
    return true
  end

  def shot_sphere()
    camPos = @ui.get_camera().get_position()
    camDir = @ui.get_camera().get_direction()

    object_info = SphereObjectInfo.new(0.75)
    object_info.material_name = "Examples/SphereMappedRustySteel"
    box = @garden.create_object("shotSphere#{@shot_num}", object_info, PhysicsInfo.new(1.0))
    box.set_position(camPos + (camDir * 5.0))
    @shot_num += 1
    
    force = camDir * Vector3D.new(100.0, 100.0, 100.0)
    box.apply_impulse(force, Vector3D.new(0.0, 0.0, 0.0))
  end
end

garden = create_garden(BulletRagdoll)
garden.run()

require 'teien'

require_relative './user_event'

include Teien

class HelloGardenModel
  def initialize(garden)
    @garden = garden
    @quit = false
    @shot_num = 0

    @garden.register_receiver(self)

#    # set config files.
#    fileDir = File.dirname(File.expand_path(__FILE__))
#    @garden.plugins_cfg = "#{fileDir}/plugins.cfg"
#    @garden.resources_cfg = "#{fileDir}/resources.cfg"
  end

  def setup(garden)
    puts "model setup"

    @garden = garden

    @garden.set_ambient_light(Color.new(0.1, 0.1, 0.1))
    @garden.set_sky_dome(true, "Examples/CloudySky", 5, 8)
    @garden.set_gravity(Vector3D.new(0.0, -9.8, 0.0))

    # create a light
    object_info = LightObjectInfo.new(LightObjectInfo::DIRECTIONAL)
    object_info.diffuse_color = Color.new(1.0, 1.0, 1.0)
    object_info.specular_color = Color.new(0.25, 0.25, 0)
    object_info.direction = Vector3D.new( -1, -1, -1 )
    light = @garden.create_object("light", object_info, PhysicsInfo.new(0))
    light.set_position(Vector3D.new(0, 0, 0))

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

=begin
    # create a mesh object
    object_info = MeshObjectInfo.new("penguin.mesh")
    object_info.scale = Vector3D.new(1.0 / 20.0, 1.0 / 20.0, 1.0 / 20.0)
    pen = @garden.create_object("penpen", object_info, PhysicsInfo.new(10))
    pen.set_position(Vector3D.new(1, 20, 0))
=end
  end

  def update(delta)
#    print "Garden tick is called: ", evt.timeSinceLastFrame * 1000, "\n"
    return !@quit
  end

  def shot_box(pos, dir)
    object_info = BoxObjectInfo.new(Vector3D.new(1, 1, 1))
    object_info.material_name = "Examples/SphereMappedRustySteel"
    box = @garden.create_object("shotBox#{@shot_num}", object_info, PhysicsInfo.new(1.0))
    box.set_position(pos + (dir * 5.0))
    @shot_num += 1
    force = dir * Vector3D.new(100.0, 100.0, 100.0)
    box.apply_impulse(force, Vector3D.new(0.0, 0.0, 0.0))

    @garden.notify_object(box)
  end
end


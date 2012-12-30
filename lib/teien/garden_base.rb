require "teien/garden_object.rb"
require "teien/sky_dome.rb"
require "teien/physics.rb"
#require "teien/user_interface.rb"
#require "teien/event_router.rb"
require "teien/dispatcher.rb"

require "eventmachine"
require "teien/network.rb"

module Teien

# This is a top object of 3D world.
class GardenBase
  include Dispatcher

  attr_accessor :resources_cfg
  attr_accessor :plugins_cfg
  attr_accessor :objects
  attr_accessor :physics

  attr_accessor :gravity
  attr_accessor :ambient_light_color

  #
  # _script_klass_:: : set a user define class.
  # 
  def initialize()
    super()

    @physics = Physics.new()

    @resources_cfg = nil
    @plugins_cfg = nil

    @objects = {}
    @object_num = 0

    @debug_draw = false
    @quit = false
    @last_time = 0

    # environment value
    @gravity = nil
    @ambient_light_color = nil
    @sky_dome = nil
  end

  #
  # set the gravity of the world.
  #
  # _grav_ :: : set a vector(Vector3D) as the gravity.
  #
  def set_gravity(grav)
    @gravity = grav
    @physics.set_gravity(grav)
  end

  #
  # set the ambient light of the world.
  #
  # _color_:: : set a color(Color).
  #
  def set_ambient_light(color)
    @ambient_light_color = color
    notify(:set_ambient_light, color)
  end

  def set_sky_dome(enable, materialName, curvature = 10, tiling = 8, distance = 4000)
    @sky_dome = SkyDome.new(enable, materialName, curvature, tiling, distance)
    notify(:set_sky_dome, enable, materialName, curvature, tiling, distance)
  end

  def create_object(name, object_info, physics_info)
    obj = GardenObject.new()
    obj.name = name
    obj.object_info = object_info
    obj.physics_info = physics_info

    obj.garden = @garden
    if (@objects[obj.name] == nil)
      @objects[obj.name] = obj
      obj.id = @object_num
      @object_num += 1
#      @event_router.notify(Event::InternalAddObject.new(obj))
      @physics.add_physics_object(obj)
      notify(:create_object, obj)
    else
      raise RuntimeError, "There is a object with the same name (#{obj.name})"
    end

=begin
    event = Event::AddObject.new(name, objectInfo, physicsInfo)
    @event_router.notify(event)
=end
    return obj
#    return @object_factory.create_object(name, objectInfo, physicsInfo)
  end

  def check_collision(objectA, objectB)
    result = @physics.contact_pair_test(objectA.rigid_body, objectB.rigid_body)
    return result.collided?()
  end

  # quit the current running garden.
  def quit()
    @quit = true
  end
end

end # module 

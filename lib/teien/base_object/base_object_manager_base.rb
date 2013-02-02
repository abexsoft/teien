require 'teien/base_object/object_info'
require 'teien/base_object/physics_info'
require "teien/base_object/physics_object_factory"
require "teien/base_object/base_object"
require "teien/base_object/sky_dome"
require "teien/base_object/physics"

module Teien

# This is a top object of 3D world.
class BaseObjectManagerBase
  include Dispatcher

  attr_accessor :resources_cfg
  attr_accessor :plugins_cfg

  attr_accessor :physics
  attr_accessor :objects

  attr_accessor :gravity
  attr_accessor :ambient_light_color

  #
  # _script_klass_:: : set a user define class.
  # 
  def initialize(event_router)
    super()

    puts "initialize base_object_manager_base"

    @event_router = event_router
    @event_router.register_receiver(self)

    @physics = Physics.new()

    @objects = {}
    @object_num = 0

    @quit = false
    @debug_draw = false

    @resources_cfg = nil
    @plugins_cfg = nil

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
    if (@objects[name])
      #raise RuntimeError, "There is a object with the same name (#{obj.name})"
      puts "There is a object with the same name (#{name})"
      return @objects[name]
    else
      obj = BaseObject.new()
      obj.name = name
      obj.object_info = object_info
      obj.physics_info = physics_info

      obj.manager = self
      @objects[obj.name] = obj
      obj.id = @object_num
      @object_num += 1
      @physics.add_physics_object(obj)
      notify(:create_object, obj)
      return obj
    end
  end

  def add_actor(actor)
    if (@actors[actor.name] == nil)
      actors[name] = actor
      notify(:add_actor, actor)
    else
      raise RuntimeError, "There is an actor with the same name (#{actor.name})"
    end
  end

  def check_collision(objectA, objectB)
    result = @physics.contact_pair_test(objectA.rigid_body, objectB.rigid_body)
    return result.collided?()
  end

  # quit the current running process.
  def quit()
    @quit = true
  end
end

end # module 

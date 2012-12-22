require "teien/garden_object.rb"
require "teien/sky_dome.rb"
require "teien/object_factory.rb"
require "teien/view.rb"
require "teien/physics.rb"
require "teien/user_interface.rb"
require "teien/event_router.rb"

require "eventmachine"
require "teien/network.rb"

module Teien

# This is a top object of 3D world.
class GardenBase

  attr_accessor :resources_cfg
  attr_accessor :plugins_cfg
  attr_accessor :objects
  attr_accessor :object_factory
  attr_accessor :physics
  attr_accessor :event_router

  attr_accessor :title
  attr_accessor :gravity
  attr_accessor :ambient_light_color
  #
  # _script_klass_:: : set a user define class.
  # 
  def initialize(script_klass)
    @script_klass = script_klass
    @event_router = EventRouter.new

    @view = nil
    @physics = nil

    @resources_cfg = nil
    @plugins_cfg = nil
    @objects = {}
    @object_num = 0
    @object_factory = nil 

    @debug_draw = false
    @quit = false
    @last_time = 0

    # environment value
    @title = nil
    @gravity = nil
    @ambient_light_color = nil
    @sky_dome = nil
  end

  #
  # set a title name on the window title bar.
  #
  # _title_ :: : set a name(String).
  #
  def set_window_title(title)
    @title = title
  end
  
  #
  # set the gravity of the world.
  #
  # _grav_ :: : set a vector(Vector3D) as the gravity.
  #
  def set_gravity(grav)
    @gravity = grav
  end

  #
  # set the ambient light of the world.
  #
  # _color_:: : set a color(Color).
  #
  def set_ambient_light(color)
    @ambient_light_color = color
  end

  def set_sky_dome(enable, materialName, curvature = 10, tiling = 8, distance = 4000)
    @sky_dome = SkyDome.new(enable, materialName, curvature, tiling, distance)
  end

  def create_user_interface()
    "This method should be overwritten."
  end

  def create_object(name, objectInfo, physicsInfo)
    return @object_factory.create_object(name, objectInfo, physicsInfo)
  end

=begin
  def create_light(name)
    obj = LightObject.new(self, name)
    add_object(obj)
    return obj
  end
=end

  def add_object(obj, collision_filter = nil)
    if (@objects[obj.name] == nil)
      if (obj.rigid_body != nil && obj.object_info.class != LightObjectInfo)
        if (collision_filter)
          @physics.add_rigid_body(obj.rigid_body, collision_filter) 
        else
          @physics.add_rigid_body(obj.rigid_body) 
        end
      end
      @objects[obj.name] = obj
      obj.id = @object_num
      @object_num += 1
    else
      raise RuntimeError, "There is a object with the same name (#{obj.name})"
    end
  end

  def check_collision(objectA, objectB)
    result = @physics.contact_pair_test(objectA.rigid_body, objectB.rigid_body)
    return result.collided?()
  end

  def update()
    return true
  end


  # quit the current running garden.
  def quit()
    @quit = true
  end
end

end # module 

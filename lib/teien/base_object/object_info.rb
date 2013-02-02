module Teien

class ObjectInfo
  attr_accessor :use_physics

  def initialize()
    @use_physics = false
  end
end

require_relative "std_objects/light_object_info"
require_relative "std_objects/floor_object_info"
require_relative "std_objects/mesh_bb_object_info"
require_relative "std_objects/mesh_object_info"
require_relative "std_objects/box_object_info"
require_relative "std_objects/sphere_object_info"
require_relative "std_objects/capsule_object_info"
require_relative "std_objects/cone_object_info"
require_relative "std_objects/cylinder_object_info"

end

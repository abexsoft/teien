require_relative "../physics_object_factory"

module Teien

class FloorObjectInfo < ObjectInfo
  attr_accessor :width
  attr_accessor :height
  attr_accessor :depth
  attr_accessor :num_seg_x
  attr_accessor :num_seg_y
  attr_accessor :u_tile
  attr_accessor :v_tile
  attr_accessor :material_name

  def initialize(width, height, depth = 0.5, num_seg_x = 1, num_seg_y = 1, u_tile = 1.0, v_tile = 1.0)
    super()
    @width   = width
    @height  = height
    @depth   = depth
    @num_seg_x = num_seg_x
    @num_seg_y = num_seg_y
    @u_tile   = u_tile
    @v_tile   = v_tile
    @material_name = nil
  end

  # Setting a collision shape and a rigid body of Bullet.
  def self.create_physics_object(obj, physics)
    physics_object = PhysicsObject.new(physics)
    cShape = Bullet::BtBoxShape.new(Vector3D.new(obj.object_info.width, 
                                                 obj.object_info.depth, 
                                                 obj.object_info.height))
    physics_object.set_rigid_body(obj, cShape, 
                                  Vector3D.new(0, 0, 0), 
                                  Vector3D.new(0.0, -obj.object_info.depth, 0.0))

    obj.object_info.use_physics = true

    return physics_object
  end

  PhysicsObjectFactory::set_creator(self, self.method(:create_physics_object))
end

end

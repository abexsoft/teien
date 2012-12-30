module Teien

class PhysicsObject
  # Bullet accessor
  attr_accessor :rigid_body # shows the center of this object.
  attr_accessor :transform
  attr_accessor :pivot_shape
  attr_accessor :shape
  attr_accessor :acceleration
  attr_accessor :maxHorizontalVelocity
  attr_accessor :maxVerticalVelocity

  def initialize(physics)
    @physics = physics
    @rigid_body = nil
    @transform = Bullet::BtTransform.new()
    @transform.set_identity()
    @acceleration = Vector3D.new(0, 0, 0)

    @maxHorizontalVelocity = 0
    @maxVerticalVelocity = 0
  end

  #
  # The offset changes the local position of the shape(collision shape) in Object.
  #
  def set_rigid_body(obj, shape, inertia, offset = Vector3D.new(0, 0, 0))
#    puts "offset(#{offset.x}, #{offset.y}, #{offset.z})"
    @pivot_shape = Bullet::BtCompoundShape.new
    localTrans = Bullet::BtTransform.new
    localTrans.set_identity()
    localTrans.set_origin(offset)
    @pivot_shape.add_child_shape(localTrans, shape)
    @shape = shape
#    @rigid_body = @physics.create_rigid_body(obj.physics_info.mass, obj, @pivot_shape, inertia)
    @rigid_body = create_rigid_body(obj.physics_info.mass, obj, @pivot_shape, inertia)
    @rigid_body.set_angular_factor(obj.physics_info.angular_factor)
    @rigid_body.set_restitution(obj.physics_info.restitution)
    @rigid_body.set_friction(obj.physics_info.friction)
    @rigid_body.set_damping(obj.physics_info.linear_damping, 
                            obj.physics_info.angular_damping)
    return @rigid_body
  end

  def create_rigid_body(mass, motionState, colObj, inertia)
    rigid_body = Bullet::BtRigidBody.new(mass, motionState, colObj, inertia)
    rigid_body.instance_variable_set(:@collision_shape, colObj) # prevent this colObj from GC.
    return rigid_body
  end

end

end

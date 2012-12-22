require "teien/tools.rb"
require "teien/animation_operator.rb"

module Teien

#
# GardenObject has a rigidBody(bullet physics), an entity and a sceneNode(ogre3d view).
#
class GardenObjectBase < Bullet::BtMotionState
  # object ID
  attr_accessor :id
  attr_accessor :name
  attr_accessor :mode

  attr_accessor :object_info
  attr_accessor :physics_info

  # Bullet accessor
  attr_accessor :rigid_body # shows the center of this object.
  attr_accessor :pivot_shape
  attr_accessor :shape

  # Ogre3D accessor
  ## center of view objects(sceneNode) and kept to equal with the rigid_body position.
  attr_accessor :pivot_scene_node 
  attr_accessor :scene_node
  attr_accessor :entity

  MODE_FREE = 0
  MODE_ATTACHED = 1

  def initialize(garden)
    super()
    @id = -1
    @garden = garden
    @mode = MODE_FREE

    @pivot_scene_node = nil
    @scene_node = nil
    @entity = nil

    @rigid_body = nil
    @transform = Bullet::BtTransform.new()
    @transform.set_identity()
    @acceleration = Vector3D.new(0, 0, 0)

    @maxHorizontalVelocity = 0
    @maxVerticalVelocity = 0
  end

  #
  # The offset changes the local position of the created scene_node in Object.
  #
  def create_scene_node(entity, offset = Vector3D.new(0, 0, 0), rotate = Quaternion.new(0, 0, 0, 1.0))
    if (@pivot_scene_node == nil)
      @pivot_scene_node = @garden.view.scene_mgr.get_root_scene_node().create_child_scene_node()
    end
    @scene_node = @pivot_scene_node.create_child_scene_node(Vector3D.to_ogre(offset), 
                                                            Quaternion.to_ogre(rotate))
    @pivot_scene_node.instance_variable_set(:@child, @scene_node) # prevent this from GC.

    if entity
      @scene_node.attach_object(entity)
      @entity = entity
    end

    return @scene_node
  end

  #
  # The offset changes the local position of the shape(collision shape) in Object.
  #
  def create_rigid_body(mass, shape, inertia, offset = Vector3D.new(0, 0, 0))
#    puts "offset(#{offset.x}, #{offset.y}, #{offset.z})"
    @pivot_shape = Bullet::BtCompoundShape.new
    localTrans = Bullet::BtTransform.new
    localTrans.set_identity()
    localTrans.set_origin(offset)
    @pivot_shape.add_child_shape(localTrans, shape)
    @shape = shape
    @rigid_body = @garden.physics.create_rigid_body(mass, self, @pivot_shape, inertia)
  end

  def create_animation_operator()
    return AnimationOperator.new(@entity)
  end

  def set_activation_state(state)
    @rigid_body.set_activation_state(state)
  end


  # Set a position.
  # 
  # ==== Args
  # [aPos: Vector3D] 
  def set_position(aPos)
#    @pivot_scene_node.set_position(aPos.x, aPos.y, aPos.z) unless @garden.is_server
    @transform.set_origin(Bullet::BtVector3.new(aPos.x, aPos.y, aPos.z))
    @rigid_body.set_center_of_mass_transform(@transform) if (@rigid_body != nil)
  end

  # Set a linear velocity.
  #
  # ==== Args
  # [aVel: Vector3D] 
  def set_linear_velocity(aVel)
    @rigid_body.activate(true)
    @rigid_body.set_linear_velocity(aVel)
  end

  # Set an angular velocity.
  #
  # ==== Args
  # [vel: Vector3D] 
  def set_angular_velocity(vel)
    @rigid_body.set_angular_velocity(vel)
  end

  # Set a max horizontal velocity.
  #
  # ==== Args
  # [vel: Vector3D] vel is the max velocity. 0 means there is no limit.
  def set_max_horizontal_velocity(vel_len)
    @maxHorizontalVelocity = vel_len
  end

  # Set a max vertical velocity.
  #
  # ==== Args
  # [vel: Vector3D] vel is the max velocity. 0 means there is no limit.
  def set_max_vertical_velocity(vel_le)
    @maxVerticalVelocity = vel_len
  end

  # Set the object's acceleration.
  def set_acceleration(acc)
    @acceleration = acc
  end

  def set_gravity(grav)
    @rigid_body.set_gravity(grav)
  end

  def set_rotation(quad)
    transform = @rigid_body.get_center_of_mass_transform()
    transform.set_rotation(quad)
    @rigid_body.set_center_of_mass_transform(transform)
  end

  def set_collision_filter(filter)
    @garden.physics.dynamicsWorld.remove_rigid_body(@rigid_body)
    @garden.physics.dynamicsWorld.add_rigid_body(@rigid_body, filter.group, filter.mask)
    physics_info.collisionFilter = filter
  end

  def set_world_transform(worldTrans)
    @transform = Bullet::BtTransform.new(worldTrans) if (@mode == MODE_FREE)
  end

  def get_world_transform(worldTrans)
#    puts "getWorldTransform"
  end

  def get_activation_state()
    @rigid_body.get_activation_state()
  end

  def get_mass()
    return 1.0 / @rigid_body.get_inv_mass()
  end

  def get_inv_mass()
    return @rigid_body.get_inv_mass()
  end

  def get_collision_mask()
    @rigid_body.get_broadphase_handle().m_collisionFilterMask
  end

  def get_position()
    newPos = @transform.get_origin()
    return newPos
  end

  def get_linear_velocity()
    return @rigid_body.get_linear_velocity()
  end

  def get_angular_velocity()
    return @rigid_body.get_angular_velocity()
  end

  def get_acceleration()
    return @acceleration
  end

  def get_gravity()
    return @rigid_body.get_gravity()
  end

  def get_rotation()
    return @transform.get_rotation()
  end

  def get_orientation()
    return @transform.get_rotation()
  end

  def limit_velocity(vel)
    newVel = Bullet::BtVector3.new(vel.x, vel.y, vel.z)

    hLen = Math::sqrt(vel.x * vel.x + vel.z * vel.z)
    if (@maxHorizontalVelocity != 0 && hLen > @maxHorizontalVelocity)
      newVel.x = vel.x / hLen * @maxHorizontalVelocity
      newVel.z = vel.z / hLen * @maxHorizontalVelocity
    end

    vLen = vel.y
    if (@maxVerticalVelocity != 0 && vLen > @maxVerticalVelocity)
      newVel.y = @maxVerticalVelocity
    end

#    puts "newVel: (#{newVel.x}, #{newVel.y}, #{newVel.z})"
    
    return newVel
  end

  def apply_impulse(imp, rel = Vector3D.new(0, 0, 0))
    @rigid_body.activate(true)
    @rigid_body.apply_impulse(imp, rel)
  end

  #
  # ====Args
  # [angle : radians] angle around y-axis.
#  def yaw(angle, relativeTo=Ogre::Node::TS_LOCAL)
  def yaw(angle)
    rotate(Quaternion.new(Vector3D.new(0, 1.0, 0), angle))
  end

  def rotate(quat)
    qnorm = Quaternion.new()
    qnorm.copy(quat)
    qnorm.normalize()
    transform = @rigid_body.get_center_of_mass_transform()
    curRot = transform.get_rotation()
    @newRot = curRot * qnorm
    transform.set_rotation(@newRot)
    @rigid_body.set_center_of_mass_transform(transform)
  end

=begin
  def attach_object_to_bone(boneName, obj)
    obj.scene_node.detach_object(obj.entity)
    tag = @entity.attach_object_to_bone(boneName, obj.entity)
    @garden.physics.dynamics_world.remove_rigid_body(obj.rigid_body)
    obj.mode = MODE_ATTACHED
    return tag
  end

  def detach_object_from_bone(obj)
    @entity.detach_object_from_bone(obj.entity)
    obj.scene_node.attach_object(obj.entity)
    if obj.physics_info.collision_filter
      @garden.physics.dynamics_world.add_rigid_body(obj.rigid_body, 
                                                    obj.physics_info.collision_filter.group,
                                                    obj.physics_info.collision_filter.mask)
    else
      @garden.physics.dynamics_world.add_rigid_body(obj.rigid_body)
    end
    obj.mode = MODE_FREE
  end
=end

  def update(delta)
  end

  def pull()
    pos = get_position()
    return [@id, pos.x, pos.y, pos.z].pack("NNNN")
  end
  
  def push(packedData)
    data = packedData.unpack("NNNN")
    posX = data[1]
    posY = data[2]
    posZ = data[3]
    
    puts "#{@id}: (#{posX}, #{posY}, #{posZ})"
    
    set_position(Vector3D.new(posX, posY, posZ))
  end
end


end # module

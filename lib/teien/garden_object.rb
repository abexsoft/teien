require "teien/tools.rb"
require "teien/physics_object.rb"
require "teien/view_object.rb"

module Teien

#
# GardenObject has a rigidBody(bullet physics), an entity and a sceneNode(ogre3d view).
#
class GardenObject < Bullet::BtMotionState
  # object ID
  attr_accessor :id
  attr_accessor :name
  attr_accessor :mode

  attr_accessor :object_info
  attr_accessor :physics_info
  attr_accessor :animation_info

  attr_accessor :garden
  attr_accessor :physics_object
  attr_accessor :view_object

  MODE_FREE = 0
  MODE_ATTACHED = 1

  def initialize()
    super()
    @id = -1
    @mode = MODE_FREE

    @garden = nil
    @physics_object = nil
    @view_object = nil
    @animation_info = Animation.new
  end

  def finalize()
    @view_object.finalize() if @view_object
    @physics_object.finalize()
  end

  def set_activation_state(state)
    @physics_object.rigid_body.set_activation_state(state)
  end


  # Set a position.
  # 
  # ==== Args
  # [aPos: Vector3D] 
  def set_position(aPos)
    
#    @pivot_scene_node.set_position(aPos.x, aPos.y, aPos.z) unless @garden.is_server
    @physics_object.transform.set_origin(Bullet::BtVector3.new(aPos.x, aPos.y, aPos.z))
    @physics_object.rigid_body.set_center_of_mass_transform(@physics_object.transform) if (@physics_object.rigid_body != nil)

    # view
    if (@view_object)
      if (object_info.class == LightObjectInfo)
        @view_object.entity.set_position(Vector3D.to_ogre(aPos))
      else        
        @view_object.pivot_scene_node.set_position(aPos.x, aPos.y, aPos.z)
      end
    end
  end

  def set_position_with_interpolation(pos)
    ip_pos = (get_position() + Vector3D.to_bullet(pos)) / 2
    @physics_object.transform.set_origin(ip_pos)
    @physics_object.rigid_body.set_center_of_mass_transform(@physics_object.transform) if (@physics_object.rigid_body != nil)
  end

  # Set a linear velocity.
  #
  # ==== Args
  # [aVel: Vector3D] 
  def set_linear_velocity(aVel)
    @physics_object.rigid_body.activate(true)
    @physics_object.rigid_body.set_linear_velocity(aVel)
  end

  def set_linear_velocity_with_interpolation(vel)
    ip_vel = (get_linear_velocity() + Vector3D.to_bullet(vel)) / 2
    @physics_object.rigid_body.activate(true)
    @physics_object.rigid_body.set_linear_velocity(ip_vel)
  end

  # Set an angular velocity.
  #
  # ==== Args
  # [vel: Vector3D] 
  def set_angular_velocity(vel)
    @physics_object.rigid_body.activate(true)
    @physics_object.rigid_body.set_angular_velocity(vel)
  end

  def set_angular_velocity_with_interpolation(vel)
    @physics_object.rigid_body.activate(true)
    ip_vel = (get_angular_velocity() + Vector3D.to_bullet(vel)) / 2
    @physics_object.rigid_body.set_angular_velocity(ip_vel)
  end

  # Set a max horizontal velocity.
  #
  # ==== Args
  # [vel: Vector3D] vel is the max velocity. 0 means there is no limit.
  def set_max_horizontal_velocity(vel_len)
    @physics_object.maxHorizontalVelocity = vel_len
  end

  # Set a max vertical velocity.
  #
  # ==== Args
  # [vel: Vector3D] vel is the max velocity. 0 means there is no limit.
  def set_max_vertical_velocity(vel_le)
    @physics_object.maxVerticalVelocity = vel_len
  end

  # Set the object's acceleration.
  def set_acceleration(acc)
    @physics_object.acceleration = acc
  end

  def set_gravity(grav)
    @physics_object.rigid_body.set_gravity(grav)
  end

  def set_damping(linear_damping, angular_damping)
    @physics_object.rigid_body.set_damping(linear_damping, angular_damping)
    @physics_info.linear_damping = linear_damping
    @physics_info.angular_damping = angular_damping
    # notify?
  end

  def set_rotation(quad)
    @physics_object.rigid_body.activate(true)
    @physics_object.transform = @physics_object.rigid_body.get_center_of_mass_transform()
    @physics_object.transform.set_rotation(quad)
    @physics_object.rigid_body.set_center_of_mass_transform(@physics_object.transform)
  end

  def set_rotation_with_interpolation(quad)
    @physics_object.rigid_body.activate(true)
    ip_quad = get_rotation().slerp(Quaternion.to_bullet(quad), 0.5)
    @physics_object.transform = @physics_object.rigid_body.get_center_of_mass_transform()
    @physics_object.transform.set_rotation(ip_quad)
    @physics_object.rigid_body.set_center_of_mass_transform(@physics_object.transform)
  end

  def set_collision_filter(filter)
    @garden.physics.dynamicsWorld.remove_rigid_body(@physics_object.rigid_body)
    @garden.physics.dynamicsWorld.add_rigid_body(@physics_object.rigid_body, filter.group, filter.mask)
    physics_info.collisionFilter = filter
  end

  def set_world_transform(worldTrans)
    @physics_object.transform = Bullet::BtTransform.new(worldTrans) if (@mode == MODE_FREE)

    if (@view_object)
      if (@mode == MODE_FREE)
        newPos = @physics_object.transform.get_origin()
        newRot = @physics_object.transform.get_rotation()
        # puts "newRot(#{id}: #{newRot.x}, #{newRot.y}, #{newRot.z}, #{newRot.w})"
        # puts "newPos(#{id}: #{newPos.x}, #{newPos.y}, #{newPos.z})"
        
        return if (newRot.x.nan?)
        
        @view_object.pivot_scene_node.set_position(newPos.x, newPos.y, newPos.z) 
        @view_object.pivot_scene_node.set_orientation(newRot.w, newRot.x, newRot.y, newRot.z)
      end
    end
  end

  def get_world_transform(worldTrans)
#    puts "getWorldTransform"
  end

  def get_activation_state()
    @physics_object.rigid_body.get_activation_state()
  end

  def get_mass()
    return 1.0 / @physics_object.rigid_body.get_inv_mass()
  end

  def get_inv_mass()
    return @physics_object.rigid_body.get_inv_mass()
  end

  def get_collision_mask()
    @physics_object.rigid_body.get_broadphase_handle().m_collisionFilterMask
  end

  def get_position()
    newPos = @physics_object.transform.get_origin()
    return newPos
  end

  def get_linear_velocity()
    return @physics_object.rigid_body.get_linear_velocity()
  end

  def get_angular_velocity()
    return @physics_object.rigid_body.get_angular_velocity()
  end

  def get_acceleration()
    return @physics_object.acceleration
  end

  def get_gravity()
    return @physics_object.rigid_body.get_gravity()
  end

  def get_rotation()
    return @physics_object.transform.get_rotation()
  end

  def get_orientation()
    return @physics_object.transform.get_rotation()
  end

  def limit_velocity(vel)
    newVel = Bullet::BtVector3.new(vel.x, vel.y, vel.z)

    hLen = Math::sqrt(vel.x * vel.x + vel.z * vel.z)
    if (@physics_object.maxHorizontalVelocity != 0 && hLen > @physics_object.maxHorizontalVelocity)
      newVel.x = vel.x / hLen * @physics_object.maxHorizontalVelocity
      newVel.z = vel.z / hLen * @physics_object.maxHorizontalVelocity
    end

    vLen = vel.y
    if (@physics_object.maxVerticalVelocity != 0 && vLen > @physics_object.maxVerticalVelocity)
      newVel.y = @physics_object.maxVerticalVelocity
    end

#    puts "newVel: (#{newVel.x}, #{newVel.y}, #{newVel.z})"
    
    return newVel
  end

  def apply_impulse(imp, rel = Vector3D.new(0, 0, 0))
    @physics_object.rigid_body.activate(true)
    @physics_object.rigid_body.apply_impulse(imp, rel)
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
    transform = @physics_object.rigid_body.get_center_of_mass_transform()
    curRot = transform.get_rotation()
    @newRot = curRot * qnorm
    transform.set_rotation(@newRot)
    @physics_object.rigid_body.set_center_of_mass_transform(transform)

    if (@view_object)
      @view_object.pivot_scene_node.set_orientation(Quaternion.to_ogre(@newRot))
    end
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

end


end # module

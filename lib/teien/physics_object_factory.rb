require 'teien/garden_object'

module Teien

class PhysicsObjectFactory
  def initialize(physics)
    @physics = physics
  end

  def create_object(obj)
    case obj.object_info
    when LightObjectInfo
      return create_light_object(obj)
    when FloorObjectInfo
      return create_floor_object(obj)
    when BoxObjectInfo
      return create_box_object(obj)
    when SphereObjectInfo
      return create_sphere_object(obj)
    when CapsuleObjectInfo
      return create_capsule_object(obj)
    when ConeObjectInfo
      return create_cone_object(obj)
    when CylinderObjectInfo
      return create_cylinder_object(obj)
    when MeshBBObjectInfo
      return create_meshBB_object(obj)
    when MeshObjectInfo
      return create_mesh_object(obj)
    else
      puts "Error: passed no supported object_info."
      return nil
    end
  end

  def create_light_object(obj)
    physics_object = PhysicsObject.new(@physics)
    cShape = Bullet::BtSphereShape.new(0.1)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(0, inertia)
    physics_object.set_rigid_body(obj, cShape, inertia)
    return physics_object
  end

  #
  # Floor Object
  #

  # Setting a collision shape and a rigid body of Bullet.
  def create_floor_object(obj)
    physics_object = PhysicsObject.new(@physics)
    cShape = Bullet::BtBoxShape.new(Vector3D.new(obj.object_info.width, 
                                                 obj.object_info.depth, 
                                                 obj.object_info.height))
    physics_object.set_rigid_body(obj, cShape, 
                                  Vector3D.new(0, 0, 0), 
                                  Vector3D.new(0.0, -obj.object_info.depth, 0.0))
    return physics_object
  end

  #
  # Box Object
  #

  def create_box_object(obj)
    physics_object = PhysicsObject.new(@physics)
    cShape = Bullet::BtBoxShape.new(Vector3D.new(obj.object_info.size.x, 
                                                 obj.object_info.size.y, 
                                                 obj.object_info.size.z))
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    physics_object.set_rigid_body(obj, cShape, inertia)
    return physics_object
  end

  # 
  # Sphere Object
  #

  def create_sphere_object(obj)
    physics_object = PhysicsObject.new(@physics)
    cShape = Bullet::BtSphereShape.new(obj.object_info.radius)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    physics_object.set_rigid_body(obj, cShape, inertia)
    return physics_object
  end

  #
  # Capsule Object
  #

  def create_capsule_object(obj)
    physics_object = PhysicsObject.new(@physics)
    cShape = Bullet::BtCapsuleShape.new(obj.object_info.radius, 
                                        obj.object_info.height)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    physics_object.set_rigid_body(obj, cShape, inertia)
    return physics_object
  end

  #
  # Cone Object
  #

  def create_cone_object(obj)
    physics_object = PhysicsObject.new(@physics)
    cShape = Bullet::BtConeShape.new(obj.object_info.radius, obj.object_info.height)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    physics_object.set_rigid_body(obj, cShape, inertia, 
                                  Vector3D.new(0, obj.object_info.height / 2, 0))
    return physics_object
  end

  #
  # Cylinder Object
  #

  def create_cylinder_object(obj)
    physics_object = PhysicsObject.new(@physics)
    cShape = Bullet::BtCylinderShape.new(Bullet::BtVector3.new(obj.object_info.radius, 
                                                               obj.object_info.height / 2, 
                                                               obj.object_info.radius))
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    physics_object.set_rigid_body(obj, cShape, inertia)
    return physics_object
  end

  #
  # MeshBB Object
  #

  def create_meshBB_object(obj)
    physics_object = PhysicsObject.new(@physics)
    cShape = Bullet::BtBoxShape.new(obj.object_info.size)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    physics_object.set_rigid_body(obj, cShape, inertia, obj.object_info.physics_offset)
    return physics_object
  end

  #
  # Mesh Object
  #

  # This method needs the obj.entity to create a collision shape. 
  # So it's not support to use this method on server(physics only) currently.
  def add_mesh_object(obj)
    physics_object = PhysicsObject.new(@physics)
    strider = Teienlib::MeshStrider.new(obj.entity.get_mesh().get())
    cShape = Bullet::BtGImpactMeshShape.new(strider)
    cShape.set_local_scaling(Bullet::BtVector3.new(obj.object_info.scale.x, 
                                                   obj.object_info.scale.y, 
                                                   obj.object_info.scale.z))
    cShape.instance_variable_set(:@strider, strider) # prevent this from GC.
    cShape.post_update()
    cShape.update_bound()
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    physics_object.set_rigid_body(obj, cShape, inertia, 
                                  obj.object_info.physics_offset)
    return physics_object
  end
end


end

require 'teien/garden_object'

module Teien

class ObjectFactory
  def initialize(garden)
    @garden = garden
  end

  def create_object(name, object_info, physics_info)
    case object_info
    when FloorObjectInfo
      return create_floor_object(name, object_info, physics_info)
    when BoxObjectInfo
      return create_box_object(name, object_info, physics_info)
    when SphereObjectInfo
      return create_sphere_object(name, object_info, physics_info)
    when CapsuleObjectInfo
      return create_capsule_object(name, object_info, physics_info)
    when ConeObjectInfo
      return create_cone_object(name, object_info, physics_info)
    when CylinderObjectInfo
      return create_cylinder_object(name, object_info, physics_info)
    when MeshBBObjectInfo
      return create_meshBB_object(name, object_info, physics_info)
    when MeshObjectInfo
      return create_mesh_object(name, object_info, physics_info)
    else
      puts "Error: passed no supported object_info."
    end
  end

  private

  def create_floor_object(name, object_info, physics_info)
    obj = GardenObject.new(@garden)
    obj.name = name
    obj.object_info = object_info
    obj.physics_info = physics_info

    unless @garden.is_server
      # Setting an entity and a node of Ogre3d.
      normal = Ogre::Vector3.new(0, 1, 0)
      up = Ogre::Vector3.new(0, 0, 1)
      Ogre::MeshManager::get_singleton().create_plane(name, 
                                                    Ogre::ResourceGroupManager.DEFAULT_RESOURCE_GROUP_NAME,
                                                    Ogre::Plane.new(normal, 0), 
                                                    object_info.width * 2.0, 
                                                    object_info.height * 2.0, 
                                                    object_info.num_seg_x, 
                                                    object_info.num_seg_y, 
                                                    true, 1, 
                                                    object_info.u_tile, 
                                                    object_info.v_tile, up)
      entity = @garden.view.scene_mgr.create_entity(name, name)
      entity.set_cast_shadows(true)
      entity.set_material_name(object_info.material_name)
      node = obj.create_scene_node(entity)
    end

    # Setting a collision shape and rigid body of Bullet.
    cShape = Bullet::BtBoxShape.new(Vector3D.new(object_info.width, object_info.depth, object_info.height))
    rb = obj.create_rigid_body(0, cShape, Vector3D.new(0, 0, 0), Vector3D.new(0.0, -object_info.depth, 0.0))
    rb.set_angular_factor(physics_info.angular_factor)
    rb.set_restitution(physics_info.restitution)
    rb.set_friction(physics_info.friction)
    rb.set_damping(physics_info.linear_damping, physics_info.angular_damping)

    @garden.add_object(obj)
      
    return obj
  end

  def create_box_object(name, object_info, physics_info)
    obj = GardenObject.new(@garden)
    obj.name = name
    obj.object_info = object_info
    obj.physics_info = physics_info

    unless @garden.is_server
      gen = Procedural::BoxGenerator.new()
      gen.set_size_x(object_info.size.x * 2.0)
      gen.set_size_y(object_info.size.y * 2.0)
      gen.set_size_z(object_info.size.z * 2.0)
      gen.set_num_seg_x(object_info.num_seg_x)
      gen.set_num_seg_y(object_info.num_seg_y)
      gen.set_num_seg_z(object_info.num_seg_z)
      gen.set_utile(object_info.u_tile).set_vtile(object_info.v_tile).realize_mesh(name)
      entity = @garden.view.scene_mgr.create_entity(name)
      entity.set_cast_shadows(true)
      entity.set_material_name(object_info.material_name)
      node = obj.create_scene_node(entity)
    end

    cShape = Bullet::BtBoxShape.new(Vector3D.new(object_info.size.x, object_info.size.y, object_info.size.z))
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(physics_info.mass, inertia)
    rb = obj.create_rigid_body(physics_info.mass, cShape, inertia)
    rb.set_angular_factor(physics_info.angular_factor)
    rb.set_restitution(physics_info.restitution)
    rb.set_friction(physics_info.friction)
    rb.set_damping(physics_info.linear_damping, physics_info.angular_damping)


    @garden.add_object(obj)

    return obj
  end

  def create_sphere_object(name, object_info, physics_info)
    obj = GardenObject.new(@garden)
    obj.name = name
    obj.object_info = object_info
    obj.physics_info = physics_info

    unless @garden.is_server
      gen = Procedural::SphereGenerator.new()
      gen.set_radius(object_info.radius)
      gen.set_num_rings(object_info.num_rings)
      gen.set_num_segments(object_info.num_segments)
      gen.set_vtile(object_info.u_tile).set_vtile(object_info.v_tile).realize_mesh(name)
      entity = @garden.view.scene_mgr.create_entity(name)
      entity.set_cast_shadows(true)
      entity.set_material_name(object_info.material_name)
      node = obj.create_scene_node(entity)
    end

    cShape = Bullet::BtSphereShape.new(object_info.radius)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(physics_info.mass, inertia)
    rb = obj.create_rigid_body(physics_info.mass, cShape, inertia)
    rb.set_angular_factor(physics_info.angular_factor)
    rb.set_restitution(physics_info.restitution)
    rb.set_friction(physics_info.friction)
    rb.set_damping(physics_info.linear_damping, physics_info.angular_damping)

    
    @garden.add_object(obj)

    return obj
  end

  def create_capsule_object(name, object_info, physics_info)
    obj = GardenObject.new(@garden)
    obj.name = name
    obj.object_info = object_info
    obj.physics_info = physics_info

    unless @garden.is_server
      gen = Procedural::CapsuleGenerator.new()
      gen.set_radius(object_info.radius).set_height(object_info.height)
      gen.set_num_rings(object_info.num_rings)
      gen.set_num_segments(object_info.num_segments)
      gen.set_num_seg_height(object_info.num_seg_height)
      gen.set_vtile(object_info.u_tile).set_vtile(object_info.v_tile).realize_mesh(name)
      entity = @garden.view.scene_mgr.create_entity(name)
      entity.set_cast_shadows(true)
      entity.set_material_name(object_info.material_name)
      node = obj.create_scene_node(entity)
    end

    cShape = Bullet::BtCapsuleShape.new(object_info.radius, object_info.height)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(physics_info.mass, inertia)
    rb = obj.create_rigid_body(physics_info.mass, cShape, inertia)
    rb.set_angular_factor(physics_info.angular_factor)
    rb.set_restitution(physics_info.restitution)
    rb.set_friction(physics_info.friction)
    rb.set_damping(physics_info.linear_damping, physics_info.angular_damping)


    @garden.add_object(obj)

    return obj
  end

  def create_cone_object(name, object_info, physics_info)
    obj = GardenObject.new(@garden)
    obj.name = name
    obj.object_info = object_info
    obj.physics_info = physics_info

    unless @garden.is_server
      gen = Procedural::ConeGenerator.new
      gen.set_radius(object_info.radius).set_height(object_info.height)
      gen.set_num_seg_base(object_info.num_seg_base).set_num_seg_height(object_info.num_seg_height)
      gen.set_utile(object_info.u_tile).set_vtile(object_info.v_tile).realize_mesh(name)
      entity = @garden.view.scene_mgr.create_entity(name)
      entity.set_cast_shadows(true)
      entity.set_material_name(object_info.material_name)
      node = obj.create_scene_node(entity)
    end

    cShape = Bullet::BtConeShape.new(object_info.radius, object_info.height)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(physics_info.mass, inertia)
    rb = obj.create_rigid_body(physics_info.mass, cShape, inertia, Vector3D.new(0, object_info.height / 2, 0))
    rb.set_angular_factor(physics_info.angular_factor)
    rb.set_restitution(physics_info.restitution)
    rb.set_friction(physics_info.friction)
    rb.set_damping(physics_info.linear_damping, physics_info.angular_damping)


    @garden.add_object(obj)

    return obj
  end

  def create_cylinder_object(name, object_info, physics_info)
    obj = GardenObject.new(@garden)
    obj.name = name
    obj.object_info = object_info
    obj.physics_info = physics_info

    unless @garden.is_server
      gen = Procedural::CylinderGenerator.new
      gen.set_radius(object_info.radius).set_height(object_info.height).set_capped(object_info.capped)
      gen.set_num_seg_base(object_info.num_seg_base).set_num_seg_height(object_info.num_seg_height)
      gen.set_utile(object_info.u_tile).set_vtile(object_info.v_tile).realize_mesh(name)
      entity = @garden.view.scene_mgr.create_entity(name)
      entity.set_cast_shadows(true)
      entity.set_material_name(object_info.material_name)
      node = obj.create_scene_node(entity, Vector3D.new(0, -object_info.height / 2, 0))
    end

    cShape = Bullet::BtCylinderShape.new(Bullet::BtVector3.new(object_info.radius, 
                                                               object_info.height / 2, 
                                                               object_info.radius))
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(physics_info.mass, inertia)
    rb = obj.create_rigid_body(physics_info.mass, cShape, inertia)
    rb.set_angular_factor(physics_info.angular_factor)
    rb.set_restitution(physics_info.restitution)
    rb.set_friction(physics_info.friction)
    rb.set_damping(physics_info.linear_damping, physics_info.angular_damping)

    @garden.add_object(obj)

    return obj
  end

  def create_meshBB_object(name, object_info, physics_info)
    obj = GardenObject.new(@garden)
    obj.name = name
    obj.object_info = object_info
    obj.physics_info = physics_info

    unless @garden.is_server
      entity = @garden.view.scene_mgr.create_entity(name, object_info.mesh_path)
      entity.set_cast_shadows(true)
      entity.set_material_name(object_info.material_name) if object_info.material_name
      node = obj.create_scene_node(entity, object_info.view_offset, object_info.view_rotation)
      node.set_scale(object_info.size.x * object_info.scale.x, 
                     object_info.size.y * object_info.scale.y, 
                     object_info.size.z * object_info.scale.z)
    end

    cShape = Bullet::BtBoxShape.new(object_info.size)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(physics_info.mass, inertia)
    rb = obj.create_rigid_body(physics_info.mass, cShape, inertia, object_info.physics_offset)
    rb.set_angular_factor(physics_info.angular_factor)
    rb.set_restitution(physics_info.restitution)
    rb.set_friction(physics_info.friction)
    rb.set_damping(physics_info.linear_damping, physics_info.angular_damping)

    @garden.add_object(obj)

    return obj
  end

  def create_mesh_object(name, object_info, physics_info)
    obj = GardenObject.new(@garden)
    obj.name = name
    obj.object_info = object_info
    obj.physics_info = physics_info

    unless @garden.is_server
      entity = @garden.view.scene_mgr.create_entity(name, object_info.mesh_path)
      entity.set_cast_shadows(true)
      entity.set_material_name(object_info.material_name) if object_info.material_name
      node = obj.create_scene_node(entity, object_info.view_offset)
      node.set_scale(object_info.scale.x, object_info.scale.y, object_info.scale.z)
      strider = Teienlib::MeshStrider.new(entity.get_mesh().get())
      cShape = Bullet::BtGImpactMeshShape.new(strider)
      cShape.set_local_scaling(Bullet::BtVector3.new(object_info.scale.x, 
                                                     object_info.scale.y, 
                                                     object_info.scale.z))
      cShape.instance_variable_set(:@strider, strider) # prevent this from GC.
      cShape.post_update()
      cShape.update_bound()
      inertia = Bullet::BtVector3.new()
      cShape.calculate_local_inertia(physics_info.mass, inertia)
      rb = obj.create_rigid_body(physics_info.mass, cShape, inertia, object_info.physics_offset)
      rb.set_angular_factor(physics_info.angular_factor)
      rb.set_restitution(physics_info.restitution)
      rb.set_friction(physics_info.friction)
      rb.set_damping(physics_info.linear_damping, physics_info.angular_damping)
    end
    
    @garden.add_object(obj)

    return obj
  end
end


end

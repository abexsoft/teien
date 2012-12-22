require 'teien/garden_object_base'

module Teien

class ObjectFactoryBase
  def initialize(garden)
    @garden = garden
  end

#  def create_object(name, object_info, physics_info)
  def create_object_common(obj)
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
    end
  end

  def add_light_object_physics(obj)
    cShape = Bullet::BtSphereShape.new(0.1)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(0, inertia)
    rb = obj.create_rigid_body(0, cShape, inertia)
    return obj
  end

  def add_light_object_view(obj)
    entity = @garden.view.scene_mgr.create_light(obj.name)
    entity.set_type(obj.object_info.type)
    entity.set_diffuse_colour(obj.object_info.diffuse_color)
    entity.set_specular_colour(obj.object_info.specular_color)
    entity.set_direction(Vector3D.to_ogre(obj.object_info.direction))
    obj.entity = entity
    return obj
  end

  #
  # Floor Object
  #

  # Setting an entity and a node of Ogre3d.
  def add_floor_object_view(obj)
    normal = Ogre::Vector3.new(0, 1, 0)
    up = Ogre::Vector3.new(0, 0, 1)
    Ogre::MeshManager::get_singleton().create_plane(obj.name, 
                                                    Ogre::ResourceGroupManager.DEFAULT_RESOURCE_GROUP_NAME,
                                                    Ogre::Plane.new(normal, 0), 
                                                    obj.object_info.width * 2.0, 
                                                    obj.object_info.height * 2.0, 
                                                    obj.object_info.num_seg_x, 
                                                    obj.object_info.num_seg_y, 
                                                    true, 1, 
                                                    obj.object_info.u_tile, 
                                                    obj.object_info.v_tile, up)
    entity = @garden.view.scene_mgr.create_entity(obj.name, obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)
    node = obj.create_scene_node(entity)

    return obj
  end

  # Setting a collision shape and a rigid body of Bullet.
  def add_floor_object_physics(obj)
    cShape = Bullet::BtBoxShape.new(Vector3D.new(obj.object_info.width, 
                                                 obj.object_info.depth, 
                                                 obj.object_info.height))
    rb = obj.create_rigid_body(0, cShape, 
                               Vector3D.new(0, 0, 0), 
                               Vector3D.new(0.0, -obj.object_info.depth, 0.0))
    rb.set_angular_factor(obj.physics_info.angular_factor)
    rb.set_restitution(obj.physics_info.restitution)
    rb.set_friction(obj.physics_info.friction)
    rb.set_damping(obj.physics_info.linear_damping, 
                   obj.physics_info.angular_damping)
    return obj
  end

  #
  # Box Object
  #

  def add_box_object_view(obj)
    gen = Procedural::BoxGenerator.new()
    gen.set_size_x(obj.object_info.size.x * 2.0)
    gen.set_size_y(obj.object_info.size.y * 2.0)
    gen.set_size_z(obj.object_info.size.z * 2.0)
    gen.set_num_seg_x(obj.object_info.num_seg_x)
    gen.set_num_seg_y(obj.object_info.num_seg_y)
    gen.set_num_seg_z(obj.object_info.num_seg_z)
    gen.set_utile(obj.object_info.u_tile).set_vtile(obj.object_info.v_tile).realize_mesh(obj.name)
    entity = @garden.view.scene_mgr.create_entity(obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)
    node = obj.create_scene_node(entity)
    return obj
  end

  def add_box_object_physics(obj)
    cShape = Bullet::BtBoxShape.new(Vector3D.new(obj.object_info.size.x, 
                                                 obj.object_info.size.y, 
                                                 obj.object_info.size.z))
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    rb = obj.create_rigid_body(obj.physics_info.mass, cShape, inertia)
    rb.set_angular_factor(obj.physics_info.angular_factor)
    rb.set_restitution(obj.physics_info.restitution)
    rb.set_friction(obj.physics_info.friction)
    rb.set_damping(obj.physics_info.linear_damping, 
                   obj.physics_info.angular_damping)
    return obj
  end

  # 
  # Sphere Object
  #

  def add_sphere_object_view(obj)
    gen = Procedural::SphereGenerator.new()
    gen.set_radius(obj.object_info.radius)
    gen.set_num_rings(obj.object_info.num_rings)
    gen.set_num_segments(obj.object_info.num_segments)
    gen.set_vtile(obj.object_info.u_tile).set_vtile(obj.object_info.v_tile).realize_mesh(obj.name)
    entity = @garden.view.scene_mgr.create_entity(obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)
    node = obj.create_scene_node(entity)
    return obj
  end

  def add_sphere_object_physics(obj)
    cShape = Bullet::BtSphereShape.new(obj.object_info.radius)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    rb = obj.create_rigid_body(obj.physics_info.mass, cShape, inertia)
    rb.set_angular_factor(obj.physics_info.angular_factor)
    rb.set_restitution(obj.physics_info.restitution)
    rb.set_friction(obj.physics_info.friction)
    rb.set_damping(obj.physics_info.linear_damping, 
                   obj.physics_info.angular_damping)
    return obj
  end

  #
  # Capsule Object
  #

  def add_capsule_object_view(obj)
    gen = Procedural::CapsuleGenerator.new()
    gen.set_radius(obj.object_info.radius).set_height(obj.object_info.height)
    gen.set_num_rings(obj.object_info.num_rings)
    gen.set_num_segments(obj.object_info.num_segments)
    gen.set_num_seg_height(obj.object_info.num_seg_height)
    gen.set_vtile(obj.object_info.u_tile).set_vtile(obj.object_info.v_tile).realize_mesh(obj.name)
    entity = @garden.view.scene_mgr.create_entity(obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)
    node = obj.create_scene_node(entity)
    return obj
  end

  def add_capsule_object_physics(obj)
    cShape = Bullet::BtCapsuleShape.new(obj.object_info.radius, 
                                        obj.object_info.height)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    rb = obj.create_rigid_body(obj.physics_info.mass, cShape, inertia)
    rb.set_angular_factor(obj.physics_info.angular_factor)
    rb.set_restitution(obj.physics_info.restitution)
    rb.set_friction(obj.physics_info.friction)
    rb.set_damping(obj.physics_info.linear_damping, 
                   obj.physics_info.angular_damping)
    return obj
  end

  #
  # Cone Object
  #

  def add_cone_object_view(obj)
    gen = Procedural::ConeGenerator.new
    gen.set_radius(obj.object_info.radius).set_height(obj.object_info.height)
    gen.set_num_seg_base(obj.object_info.num_seg_base).set_num_seg_height(obj.object_info.num_seg_height)
    gen.set_utile(obj.object_info.u_tile).set_vtile(obj.object_info.v_tile).realize_mesh(obj.name)
    entity = @garden.view.scene_mgr.create_entity(obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)
    node = obj.create_scene_node(entity)
    return obj
  end

  def add_cone_object_physics(obj)
    cShape = Bullet::BtConeShape.new(obj.object_info.radius, obj.object_info.height)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    rb = obj.create_rigid_body(obj.physics_info.mass, cShape, inertia, 
                               Vector3D.new(0, obj.object_info.height / 2, 0))
    rb.set_angular_factor(obj.physics_info.angular_factor)
    rb.set_restitution(obj.physics_info.restitution)
    rb.set_friction(obj.physics_info.friction)
    rb.set_damping(obj.physics_info.linear_damping, 
                   obj.physics_info.angular_damping)
    return obj
  end

  #
  # Cylinder Object
  #

  def add_cylinder_object_view(obj)
    gen = Procedural::CylinderGenerator.new
    gen.set_radius(obj.object_info.radius).set_height(obj.object_info.height).set_capped(obj.object_info.capped)
    gen.set_num_seg_base(obj.object_info.num_seg_base).set_num_seg_height(obj.object_info.num_seg_height)
    gen.set_utile(obj.object_info.u_tile).set_vtile(obj.object_info.v_tile).realize_mesh(obj.name)
    entity = @garden.view.scene_mgr.create_entity(obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)
    node = obj.create_scene_node(entity, 
                                 Vector3D.new(0, -obj.object_info.height / 2, 0))
    return obj
  end

  def add_cylinder_object_physics(obj)
    cShape = Bullet::BtCylinderShape.new(Bullet::BtVector3.new(obj.object_info.radius, 
                                                               obj.object_info.height / 2, 
                                                               obj.object_info.radius))
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    rb = obj.create_rigid_body(obj.physics_info.mass, cShape, inertia)
    rb.set_angular_factor(obj.physics_info.angular_factor)
    rb.set_restitution(obj.physics_info.restitution)
    rb.set_friction(obj.physics_info.friction)
    rb.set_damping(obj.physics_info.linear_damping, 
                   obj.physics_info.angular_damping)
    return obj
  end

  #
  # MeshBB Object
  #

  def add_meshBB_object_view(obj)
    entity = @garden.view.scene_mgr.create_entity(obj.name, obj.object_info.mesh_path)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name) if obj.object_info.material_name
    node = obj.create_scene_node(entity, obj.object_info.view_offset, obj.object_info.view_rotation)
    node.set_scale(obj.object_info.size.x * obj.object_info.scale.x, 
                   obj.object_info.size.y * obj.object_info.scale.y, 
                   obj.object_info.size.z * obj.object_info.scale.z)
    return obj
  end

  def add_meshBB_object_physics(obj)
    cShape = Bullet::BtBoxShape.new(obj.object_info.size)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    rb = obj.create_rigid_body(obj.physics_info.mass, cShape, inertia, obj.object_info.physics_offset)
    rb.set_angular_factor(obj.physics_info.angular_factor)
    rb.set_restitution(obj.physics_info.restitution)
    rb.set_friction(obj.physics_info.friction)
    rb.set_damping(obj.physics_info.linear_damping, 
                   obj.physics_info.angular_damping)
    return obj
  end

  #
  # Mesh Object
  #

  def add_mesh_object_view(obj)
    entity = @garden.view.scene_mgr.create_entity(obj.name, obj.object_info.mesh_path)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name) if obj.object_info.material_name
    node = obj.create_scene_node(entity, obj.object_info.view_offset)
    node.set_scale(obj.object_info.scale.x, 
                   obj.object_info.scale.y, 
                   obj.object_info.scale.z)
    return obj
  end

  # This method needs the obj.entity to create a collision shape. 
  # So it's not support to use this method on server(physics only) currently.
  def add_mesh_object_physics(obj)
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
    rb = obj.create_rigid_body(obj.physics_info.mass, cShape, inertia, 
                               obj.object_info.physics_offset)
      rb.set_angular_factor(obj.physics_info.angular_factor)
      rb.set_restitution(obj.physics_info.restitution)
      rb.set_friction(obj.physics_info.friction)
      rb.set_damping(obj.physics_info.linear_damping, 
                     obj.physics_info.angular_damping)
    return obj
  end
end


end

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
      Ogre::MeshManager::getSingleton().createPlane(name, 
                                                    Ogre::ResourceGroupManager.DEFAULT_RESOURCE_GROUP_NAME,
                                                    Ogre::Plane.new(normal, 0), 
                                                    object_info.width * 2.0, 
                                                    object_info.height * 2.0, 
                                                    object_info.num_seg_x, 
                                                    object_info.num_seg_y, 
                                                    true, 1, 
                                                    object_info.u_tile, 
                                                    object_info.v_tile, up)
      entity = @garden.view.scene_mgr.createEntity(name, name)
      entity.setCastShadows(true)
      entity.setMaterialName(object_info.material_name)
      node = obj.create_scene_node(entity)
    end

    # Setting a collision shape and rigid body of Bullet.
    cShape = Bullet::BtBoxShape.new(Vector3D.new(object_info.width, object_info.depth, object_info.height))
    rb = obj.create_rigid_body(0, cShape, Vector3D.new(0, 0, 0), Vector3D.new(0.0, -object_info.depth, 0.0))
    rb.setAngularFactor(physics_info.angular_factor)
    rb.setRestitution(physics_info.restitution)
    rb.setFriction(physics_info.friction)
    rb.setDamping(physics_info.linear_damping, physics_info.angular_damping)

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
      gen.setSizeX(object_info.size.x * 2.0).setSizeY(object_info.size.y * 2.0).setSizeZ(object_info.size.z * 2.0)
      gen.setNumSegX(object_info.num_seg_x).setNumSegY(object_info.num_seg_y).setNumSegZ(object_info.num_seg_z)
      gen.setUTile(object_info.u_tile).setVTile(object_info.v_tile).realizeMesh(name)
      entity = @garden.view.scene_mgr.createEntity(name)
      entity.setCastShadows(true)
      entity.setMaterialName(object_info.material_name)
      node = obj.create_scene_node(entity)
    end

    cShape = Bullet::BtBoxShape.new(Vector3D.new(object_info.size.x, object_info.size.y, object_info.size.z))
    inertia = Bullet::BtVector3.new()
    cShape.calculateLocalInertia(physics_info.mass, inertia)
    rb = obj.create_rigid_body(physics_info.mass, cShape, inertia)
    rb.setAngularFactor(physics_info.angular_factor)
    rb.setRestitution(physics_info.restitution)
    rb.setFriction(physics_info.friction)
    rb.setDamping(physics_info.linear_damping, physics_info.angular_damping)


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
      gen.setRadius(object_info.radius)
      gen.setNumRings(object_info.num_rings)
      gen.setNumSegments(object_info.num_segments)
      gen.setUTile(object_info.u_tile).setVTile(object_info.v_tile).realizeMesh(name)
      entity = @garden.view.scene_mgr.createEntity(name)
      entity.setCastShadows(true)
      entity.setMaterialName(object_info.material_name)
      node = obj.create_scene_node(entity)
    end

    cShape = Bullet::BtSphereShape.new(object_info.radius)
    inertia = Bullet::BtVector3.new()
    cShape.calculateLocalInertia(physics_info.mass, inertia)
    rb = obj.create_rigid_body(physics_info.mass, cShape, inertia)
    rb.setAngularFactor(physics_info.angular_factor)
    rb.setRestitution(physics_info.restitution)
    rb.setFriction(physics_info.friction)
    rb.setDamping(physics_info.linear_damping, physics_info.angular_damping)

    
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
      gen.setRadius(object_info.radius).setHeight(object_info.height)
      gen.setNumRings(object_info.num_rings).setNumSegments(object_info.num_segments).setNumSegHeight(object_info.num_seg_height)
      gen.setUTile(object_info.u_tile).setVTile(object_info.v_tile).realizeMesh(name)
      entity = @garden.view.scene_mgr.createEntity(name)
      entity.setCastShadows(true)
      entity.setMaterialName(object_info.material_name)
      node = obj.create_scene_node(entity)
    end

    cShape = Bullet::BtCapsuleShape.new(object_info.radius, object_info.height)
    inertia = Bullet::BtVector3.new()
    cShape.calculateLocalInertia(physics_info.mass, inertia)
    rb = obj.create_rigid_body(physics_info.mass, cShape, inertia)
    rb.setAngularFactor(physics_info.angular_factor)
    rb.setRestitution(physics_info.restitution)
    rb.setFriction(physics_info.friction)
    rb.setDamping(physics_info.linear_damping, physics_info.angular_damping)


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
      gen.setRadius(object_info.radius).setHeight(object_info.height)
      gen.setNumSegBase(object_info.num_seg_base).setNumSegHeight(object_info.num_seg_height)
      gen.setUTile(object_info.u_tile).setVTile(object_info.v_tile).realizeMesh(name)
      entity = @garden.view.scene_mgr.createEntity(name)
      entity.setCastShadows(true)
      entity.setMaterialName(object_info.material_name)
      node = obj.create_scene_node(entity)
    end

    cShape = Bullet::BtConeShape.new(object_info.radius, object_info.height)
    inertia = Bullet::BtVector3.new()
    cShape.calculateLocalInertia(physics_info.mass, inertia)
    rb = obj.create_rigid_body(physics_info.mass, cShape, inertia, Vector3D.new(0, object_info.height / 2, 0))
    rb.setAngularFactor(physics_info.angular_factor)
    rb.setRestitution(physics_info.restitution)
    rb.setFriction(physics_info.friction)
    rb.setDamping(physics_info.linear_damping, physics_info.angular_damping)


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
      gen.setRadius(object_info.radius).setHeight(object_info.height).setCapped(object_info.capped)
      gen.setNumSegBase(object_info.num_seg_base).setNumSegHeight(object_info.num_seg_height)
      gen.setUTile(object_info.u_tile).setVTile(object_info.v_tile).realizeMesh(name)
      entity = @garden.view.scene_mgr.createEntity(name)
      entity.setCastShadows(true)
      entity.setMaterialName(object_info.material_name)
      node = obj.create_scene_node(entity, Vector3D.new(0, -object_info.height / 2, 0))
    end

    cShape = Bullet::BtCylinderShape.new(Bullet::BtVector3.new(object_info.radius, 
                                                               object_info.height / 2, 
                                                               object_info.radius))
    inertia = Bullet::BtVector3.new()
    cShape.calculateLocalInertia(physics_info.mass, inertia)
    rb = obj.create_rigid_body(physics_info.mass, cShape, inertia)
    rb.setAngularFactor(physics_info.angular_factor)
    rb.setRestitution(physics_info.restitution)
    rb.setFriction(physics_info.friction)
    rb.setDamping(physics_info.linear_damping, physics_info.angular_damping)

    @garden.add_object(obj)

    return obj
  end

  def create_meshBB_object(name, object_info, physics_info)
    obj = GardenObject.new(@garden)
    obj.name = name
    obj.object_info = object_info
    obj.physics_info = physics_info

    unless @garden.is_server
      entity = @garden.view.scene_mgr.createEntity(name, object_info.mesh_path)
      entity.setCastShadows(true)
      entity.setMaterialName(object_info.material_name) if object_info.material_name
      node = obj.create_scene_node(entity, object_info.view_offset, object_info.view_rotation)
      node.setScale(object_info.size.x * object_info.scale.x, 
                    object_info.size.y * object_info.scale.y, 
                    object_info.size.z * object_info.scale.z)
    end

    cShape = Bullet::BtBoxShape.new(object_info.size)
    inertia = Bullet::BtVector3.new()
    cShape.calculateLocalInertia(physics_info.mass, inertia)
    rb = obj.create_rigid_body(physics_info.mass, cShape, inertia, object_info.physics_offset)
    rb.setAngularFactor(physics_info.angular_factor)
    rb.setRestitution(physics_info.restitution)
    rb.setFriction(physics_info.friction)
    rb.setDamping(physics_info.linear_damping, physics_info.angular_damping)

    @garden.add_object(obj)

    return obj
  end

  def create_mesh_object(name, object_info, physics_info)
    obj = GardenObject.new(@garden)
    obj.name = name
    obj.object_info = object_info
    obj.physics_info = physics_info

    unless @garden.is_server
      entity = @garden.view.scene_mgr.createEntity(name, object_info.mesh_path)
      entity.setCastShadows(true)
      entity.setMaterialName(object_info.material_name) if object_info.material_name
      node = obj.create_scene_node(entity, object_info.view_offset)
      node.setScale(object_info.scale.x, object_info.scale.y, object_info.scale.z)
      strider = TeienExt::MeshStrider.new(entity.getMesh().get())
      cShape = Bullet::BtGImpactMeshShape.new(strider)
      cShape.setLocalScaling(Bullet::BtVector3.new(object_info.scale.x, 
                                                   object_info.scale.y, 
                                                   object_info.scale.z))
      cShape.instance_variable_set(:@strider, strider) # prevent this from GC.
      cShape.postUpdate()
      cShape.updateBound()
      inertia = Bullet::BtVector3.new()
      cShape.calculateLocalInertia(physics_info.mass, inertia)
      rb = obj.create_rigid_body(physics_info.mass, cShape, inertia, object_info.physics_offset)
      rb.setAngularFactor(physics_info.angular_factor)
      rb.setRestitution(physics_info.restitution)
      rb.setFriction(physics_info.friction)
      rb.setDamping(physics_info.linear_damping, physics_info.angular_damping)
    end
    
    @garden.add_object(obj)

    return obj
  end
end


end

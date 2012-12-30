require 'teien/garden_object_base'

module Teien

class ViewObjectFactory
  def initialize(view)
    @view = view
  end

#  def create_object(name, object_info, physics_info)
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
    entity = @view.scene_mgr.create_light(obj.name)
    entity.set_type(obj.object_info.type)
    entity.set_diffuse_colour(obj.object_info.diffuse_color)
    entity.set_specular_colour(obj.object_info.specular_color)
    entity.set_direction(Vector3D.to_ogre(obj.object_info.direction))

    view_object = ViewObject.new(@view)
    view_object.entity = entity
    return view_object
  end

  #
  # Floor Object
  #

  # Setting an entity and a node of Ogre3d.
  def create_floor_object(obj)
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
    entity = @view.scene_mgr.create_entity(obj.name, obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)

    view_object = ViewObject.new(@view)
    view_object.set_scene_node(entity)
    return view_object
  end

  #
  # Box Object
  #

  def create_box_object(obj)
    gen = Procedural::BoxGenerator.new()
    gen.set_size_x(obj.object_info.size.x * 2.0)
    gen.set_size_y(obj.object_info.size.y * 2.0)
    gen.set_size_z(obj.object_info.size.z * 2.0)
    gen.set_num_seg_x(obj.object_info.num_seg_x)
    gen.set_num_seg_y(obj.object_info.num_seg_y)
    gen.set_num_seg_z(obj.object_info.num_seg_z)
    gen.set_utile(obj.object_info.u_tile).set_vtile(obj.object_info.v_tile).realize_mesh(obj.name)
    entity = @view.scene_mgr.create_entity(obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)

    view_object = ViewObject.new(@view)
    view_object.set_scene_node(entity)
    return view_object
  end

  # 
  # Sphere Object
  #

  def create_sphere_object(obj)
    gen = Procedural::SphereGenerator.new()
    gen.set_radius(obj.object_info.radius)
    gen.set_num_rings(obj.object_info.num_rings)
    gen.set_num_segments(obj.object_info.num_segments)
    gen.set_vtile(obj.object_info.u_tile).set_vtile(obj.object_info.v_tile).realize_mesh(obj.name)
    entity = @view.scene_mgr.create_entity(obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)

    view_object = ViewObject.new(@view)
    view_object.set_scene_node(entity)
    return view_object
  end

  #
  # Capsule Object
  #

  def create_capsule_object(obj)
    gen = Procedural::CapsuleGenerator.new()
    gen.set_radius(obj.object_info.radius).set_height(obj.object_info.height)
    gen.set_num_rings(obj.object_info.num_rings)
    gen.set_num_segments(obj.object_info.num_segments)
    gen.set_num_seg_height(obj.object_info.num_seg_height)
    gen.set_vtile(obj.object_info.u_tile).set_vtile(obj.object_info.v_tile).realize_mesh(obj.name)
    entity = @view.scene_mgr.create_entity(obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)

    view_object = ViewObject.new(@view)
    view_object.set_scene_node(entity)
    return view_object
  end

  #
  # Cone Object
  #

  def create_cone_object(obj)
    gen = Procedural::ConeGenerator.new
    gen.set_radius(obj.object_info.radius).set_height(obj.object_info.height)
    gen.set_num_seg_base(obj.object_info.num_seg_base).set_num_seg_height(obj.object_info.num_seg_height)
    gen.set_utile(obj.object_info.u_tile).set_vtile(obj.object_info.v_tile).realize_mesh(obj.name)
    entity = @view.scene_mgr.create_entity(obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)

    view_object = ViewObject.new(@view)
    view_object.set_scene_node(entity)
    return view_object
  end

  #
  # Cylinder Object
  #

  def create_cylinder_object(obj)
    gen = Procedural::CylinderGenerator.new
    gen.set_radius(obj.object_info.radius).set_height(obj.object_info.height).set_capped(obj.object_info.capped)
    gen.set_num_seg_base(obj.object_info.num_seg_base).set_num_seg_height(obj.object_info.num_seg_height)
    gen.set_utile(obj.object_info.u_tile).set_vtile(obj.object_info.v_tile).realize_mesh(obj.name)
    entity = @view.scene_mgr.create_entity(obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)

    view_object = ViewObject.new(@view)
    view_object.set_scene_node(entity, 
                               Vector3D.new(0, -obj.object_info.height / 2, 0))
    return view_object
  end

  #
  # MeshBB Object
  #

  def create_meshBB_object(obj)
    entity = @view.scene_mgr.create_entity(obj.name, obj.object_info.mesh_path)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name) if obj.object_info.material_name

    view_object = ViewObject.new(@view)
    node = view_object.set_scene_node(entity, obj.object_info.view_offset, obj.object_info.view_rotation)
    node.set_scale(obj.object_info.size.x * obj.object_info.scale.x, 
                   obj.object_info.size.y * obj.object_info.scale.y, 
                   obj.object_info.size.z * obj.object_info.scale.z)
    return view_object
  end

  #
  # Mesh Object
  #

  def create_mesh_object(obj)
    entity = @view.scene_mgr.create_entity(obj.name, obj.object_info.mesh_path)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name) if obj.object_info.material_name

    view_object = ViewObject.new(@view)
    node = view_object.set_scene_node(entity, obj.object_info.view_offset)
    node.set_scale(obj.object_info.scale.x, 
                   obj.object_info.scale.y, 
                   obj.object_info.scale.z)
    return view_object
  end
end


end

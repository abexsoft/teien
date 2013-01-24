module Teien

class MeshObjectInfo  < ObjectInfo
  attr_accessor :mesh_path
  attr_accessor :scale         # Loading mesh only: scales mesh
  attr_accessor :view_offset    # Loading mesh only: offset of Mesh
  attr_accessor :view_rotation  # Loading mesh only: rotation offset of Mesh
  attr_accessor :physics_offset # Loading mesh only: offset of collision Box 
  attr_accessor :material_name

  def initialize(mesh_path, scale = Vector3D.new(1, 1, 1),
                 view_offset = Vector3D.new(0, 0, 0),
                 view_rotation = Quaternion.new(0, 0, 0, 1.0),
                 physics_offset = Vector3D.new(0, 0, 0))
    super()
    @mesh_path = mesh_path
    @scale = scale
    @view_offset = view_offset
    @view_rotation = view_rotation
    @physics_offset = physics_offset
    @material_name = nil
  end

  # This method needs the obj.entity to create a collision shape. 
  # So it's not support to use this method on server(physics only) currently.
  def self.create_physics_object(obj, physics)
    physics_object = PhysicsObject.new(physics)
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

    obj.object_info.use_physics = true

    return physics_object
  end

  def self.create_view_object(obj, view)
    entity = view.scene_mgr.create_entity(obj.name, obj.object_info.mesh_path)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name) if obj.object_info.material_name

    view_object = ViewObject.new(view)
    node = view_object.set_scene_node(entity, obj.object_info.view_offset)
    node.set_scale(obj.object_info.scale.x, 
                   obj.object_info.scale.y, 
                   obj.object_info.scale.z)

    obj.object_info.use_view = true

    return view_object
  end
  

  PhysicsObjectFactory::set_creator(self, self.method(:create_physics_object))
  ViewObjectFactory::set_creator(self, self.method(:create_view_object))
end

end

require_relative "../physics_object_factory"

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

    if obj.physics_info
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
    else
      # use a rigid body as a position holder only(not as collision shape).
      cShape = Bullet::BtSphereShape.new(0.1)
      inertia = Bullet::BtVector3.new()
      cShape.calculate_local_inertia(0, inertia)
      obj.physics_info = PhysicsInfo.new(0) # dummy to make a rigid body.
      physics_object.set_rigid_body(obj, cShape, inertia)
      obj.physics_info = nil
      obj.object_info.use_physics = false
    end

    return physics_object
  end

  PhysicsObjectFactory::set_creator(self, self.method(:create_physics_object))
end

end

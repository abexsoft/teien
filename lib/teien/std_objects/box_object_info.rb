module Teien

class BoxObjectInfo < ObjectInfo
  attr_accessor :size
  attr_accessor :num_seg_x
  attr_accessor :num_seg_y
  attr_accessor :num_seg_z
  attr_accessor :u_tile
  attr_accessor :v_tile
  attr_accessor :material_name

  def initialize(size, num_seg_x = 1, num_seg_y = 1, num_seg_z = 1, u_tile = 1.0, v_tile = 1.0)
    super()
    @size = size
    @num_seg_x = num_seg_x
    @num_seg_y = num_seg_y
    @num_seg_z = num_seg_z
    @u_tile   = u_tile
    @v_tile   = v_tile
    @material_name = nil
  end

  def self.create_physics_object(obj, physics)
    physics_object = PhysicsObject.new(physics)
    cShape = Bullet::BtBoxShape.new(Vector3D.new(obj.object_info.size.x, 
                                                 obj.object_info.size.y, 
                                                 obj.object_info.size.z))
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    physics_object.set_rigid_body(obj, cShape, inertia)

    obj.object_info.use_physics = true

    return physics_object
  end

  def self.create_view_object(obj, view)
    gen = Procedural::BoxGenerator.new()
    gen.set_size_x(obj.object_info.size.x * 2.0)
    gen.set_size_y(obj.object_info.size.y * 2.0)
    gen.set_size_z(obj.object_info.size.z * 2.0)
    gen.set_num_seg_x(obj.object_info.num_seg_x)
    gen.set_num_seg_y(obj.object_info.num_seg_y)
    gen.set_num_seg_z(obj.object_info.num_seg_z)
    gen.set_utile(obj.object_info.u_tile).set_vtile(obj.object_info.v_tile).realize_mesh(obj.name)
    entity = view.scene_mgr.create_entity(obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)

    view_object = ViewObject.new(view)
    view_object.set_scene_node(entity)

    obj.object_info.use_view = true

    return view_object
  end

  PhysicsObjectFactory::set_creator(self, self.method(:create_physics_object))
  ViewObjectFactory::set_creator(self, self.method(:create_view_object))
end

end

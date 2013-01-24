module Teien

class CapsuleObjectInfo < ObjectInfo
  attr_accessor :radius
  attr_accessor :height
  attr_accessor :num_rings
  attr_accessor :num_segments
  attr_accessor :num_seg_height
  attr_accessor :u_tile
  attr_accessor :v_tile
  attr_accessor :material_name

  def initialize(radius, height, num_rings = 8, num_segments = 16, num_seg_height = 1, u_tile = 1.0, v_tile = 1.0)
    super()
    @radius = radius
    @height = height
    @num_rings = num_rings
    @num_segments = num_segments
    @num_seg_height = num_seg_height
    @u_tile = u_tile
    @v_tile = v_tile
    @material_name = nil
  end

  def self.create_physics_object(obj, physics)
    physics_object = PhysicsObject.new(physics)
    cShape = Bullet::BtCapsuleShape.new(obj.object_info.radius, 
                                        obj.object_info.height)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(obj.physics_info.mass, inertia)
    physics_object.set_rigid_body(obj, cShape, inertia)

    obj.object_info.use_physics = true

    return physics_object
  end

  def self.create_view_object(obj, view)
    gen = Procedural::CapsuleGenerator.new()
    gen.set_radius(obj.object_info.radius).set_height(obj.object_info.height)
    gen.set_num_rings(obj.object_info.num_rings)
    gen.set_num_segments(obj.object_info.num_segments)
    gen.set_num_seg_height(obj.object_info.num_seg_height)
    gen.set_vtile(obj.object_info.u_tile).set_vtile(obj.object_info.v_tile).realize_mesh(obj.name)
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

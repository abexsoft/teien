require "teien/ui/view_object_factory"
require "teien/base_object/std_objects/box_object_info"

module Teien

class BoxObjectInfo
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

    return view_object
  end

  ViewObjectFactory::set_creator(self, self.method(:create_view_object))
end

end

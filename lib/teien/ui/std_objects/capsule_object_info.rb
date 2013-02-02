require "teien/ui/view_object_factory"
require "teien/base_object/std_objects/capsule_object_info"

module Teien

class CapsuleObjectInfo
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

    return view_object
  end

  ViewObjectFactory::set_creator(self, self.method(:create_view_object))
end


end

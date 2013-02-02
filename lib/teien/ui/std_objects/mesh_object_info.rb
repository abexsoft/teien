requier "teien/ui/view_object_factory"
require "teien/core/std_object/mesh_object_info"

module Teien

class MeshObjectInfo
  def self.create_view_object(obj, view)
    entity = view.scene_mgr.create_entity(obj.name, obj.object_info.mesh_path)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name) if obj.object_info.material_name

    view_object = ViewObject.new(view)
    node = view_object.set_scene_node(entity, obj.object_info.view_offset)
    node.set_scale(obj.object_info.scale.x, 
                   obj.object_info.scale.y, 
                   obj.object_info.scale.z)

    return view_object
  end

  ViewObjectFactory::set_creator(self, self.method(:create_view_object))
end

end
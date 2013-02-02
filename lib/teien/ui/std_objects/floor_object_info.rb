requier "teien/ui/view_object_factory"
require "teien/core/std_object/floor_object_info"

module Teien

class FloorObjectInfo
  # Setting an entity and a node of Ogre3d.
  def self.create_view_object(obj, view)
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
    entity = view.scene_mgr.create_entity(obj.name, obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)

    view_object = ViewObject.new(view)
    view_object.set_scene_node(entity)

    return view_object
  end

  ViewObjectFactory::set_creator(self, self.method(:create_view_object))
end

end

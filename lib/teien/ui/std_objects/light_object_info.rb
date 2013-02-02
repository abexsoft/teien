requier "teien/ui/view_object_factory"
require "teien/core/std_object/light_object_info"

module Teien

class LightObjectInfo
  def self.create_view_object(obj, view)
    entity = view.scene_mgr.create_light(obj.name)
    entity.set_type(obj.object_info.type)
    entity.set_diffuse_colour(obj.object_info.diffuse_color)
    entity.set_specular_colour(obj.object_info.specular_color)
    entity.set_direction(Vector3D.to_ogre(obj.object_info.direction))

    view_object = ViewObject.new(@view)
    view_object.entity = entity

    return view_object
  end

  ViewObjectFactory::set_creator(self, self.method(:create_view_object))
end

end

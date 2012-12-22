require "teien/garden_object.rb"

module Teien

class ProxyGardenObject < GardenObject
    def initialize(garden)
      super
    end

    def set_position(aPos)
      super

      if (object_info.class == LightObjectInfo)
        @entity.set_position(Vector3D.to_ogre(aPos))
      else        
        @pivot_scene_node.set_position(aPos.x, aPos.y, aPos.z)
      end
    end

    def set_world_transform(worldTrans)
      super

      if (@mode == MODE_FREE)
        newPos = @transform.get_origin()
        newRot = @transform.get_rotation()
        # puts "newRot(#{id}: #{newRot.x}, #{newRot.y}, #{newRot.z}, #{newRot.w})"
        # puts "newPos(#{id}: #{newPos.x}, #{newPos.y}, #{newPos.z})"

        return if (newRot.x.nan?)

        @pivot_scene_node.set_position(newPos.x, newPos.y, newPos.z) 
        @pivot_scene_node.set_orientation(newRot.w, newRot.x, newRot.y, newRot.z)
      end
    end

    def rotate(quat)    
      super
      @pivot_scene_node.set_orientation(Quaternion.to_ogre(@newRot))
    end
end

end

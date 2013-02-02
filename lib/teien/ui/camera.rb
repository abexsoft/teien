require 'teien/ui/camera_mover'

module Teien

class Camera
    def initialize(cam)
      # Ogre::Camera
      @camera = cam
      @mover = CameraMover.new(cam)
    end

    def get_mover()
      return @mover
    end

    def get_position
      return Vector3D.to_self(@camera.get_position())
    end

    def get_direction
      return Vector3D.to_self(@camera.get_direction())
    end
end

end

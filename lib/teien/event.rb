module Event

# event
class EventBase
  # allows to forward to connected networks.
  attr_accessor :forward 

  def initialize()
    @forward = false
  end
end

class ClientConnected < EventBase
end

class SyncEnv < EventBase
#  include ToControllerGroup

  attr_accessor :gravity
  attr_accessor :ambient_light_color
  attr_accessor :sky_dome

  def initialize(gravity, ambient_light_color, sky_dome)
    @gravity = gravity
    @ambient_light_color = ambient_light_color
    @sky_dome = sky_dome
  end
end

class SyncObject < EventBase
#  include ToControllerGroup

  attr_accessor :id
  attr_accessor :name
  attr_accessor :mode

  attr_accessor :object_info
  attr_accessor :physics_info

  attr_accessor :pos
  attr_accessor :linear_vel
  attr_accessor :angular_vel
  attr_accessor :quat


  def initialize(obj)
    @id = obj.id
    @name = obj.name

    @object_info = obj.object_info
    @physics_info = obj.physics_info

    @pos = Vector3D.to_self(obj.get_position())
    @linear_vel = Vector3D.to_self(obj.get_linear_velocity())
    @angular_vel = Vector3D.to_self(obj.get_angular_velocity())
    @quat = Quaternion.to_self(obj.get_rotation())
  end

  def print
    puts @name
  end
end


end # module Event

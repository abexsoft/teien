module Event

# event group
module ToModelGroup
end
module ToControllerGroup
end

# event
class KeyPressed
  attr_accessor :key

  def initialize(key)
    @key = key
  end

  def print
    puts "key pressed: #{key}"
  end
end

class KeyReleased
  attr_accessor :key

  def initialize(key)
    @key = key
  end

  def print
    puts "key released: #{key}"
  end
end

class MousePressed
  attr_accessor :event
  attr_accessor :button_id

  def initialize(ois_event, ois_button_id)
    @event = ois_event
    @button_id = ois_button_id
  end

  def print
    puts "mouse pressed"
  end
end

class MouseReleased
  attr_accessor :event
  attr_accessor :button_id

  def initialize(ois_event, ois_button_id)
    @event = ois_event
    @button_id = ois_button_id
  end

  def print
    puts "mouse released"
  end
end


class MouseMoved
  attr_accessor :event

  def initialize(ois_event)
    @event = ois_event
  end

  def print
    puts "mouse moved"
  end
end

class ClientConnected
end

class SyncEnv
  include ToControllerGroup

  attr_accessor :gravity
  attr_accessor :ambient_light_color
  attr_accessor :sky_dome

  def initialize(gravity, ambient_light_color, sky_dome)
    @gravity = gravity
    @ambient_light_color = ambient_light_color
    @sky_dome = sky_dome
  end
end

class SyncObject
  include ToControllerGroup

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

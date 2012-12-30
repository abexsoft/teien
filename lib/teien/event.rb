module Event

# event
class EventBase
  attr_accessor :forward
  # none : all, other: region number
  attr_accessor :forward_to

  def initialize()
    @forward = false
    @forward_to = Array.new
  end
end

class Tick < EventBase
  attr_accessor :delta

  def initialize(delta)
    @delta = delta
  end

  def print
    puts "delta: #{delta}"
  end
end

class Setup < EventBase
  attr_accessor :garden

  def initialize(garden)
    @garden = garden
  end

  def print
    puts "setup"
  end
end

class PhysicsUpdate < EventBase
  attr_accessor :garden
  attr_accessor :delta

  def initialize(garden, delta)
    @garden = garden
    @delta = delta
  end

  def print
    puts "delta: #{delta}"
  end
end

class UserScriptUpdate < EventBase
  attr_accessor :garden
  attr_accessor :delta

  def initialize(garden, delta)
    @garden = garden
    @delta = delta
  end

  def print
    puts "delta: #{delta}"
  end
end

class ObjectsUpdated < EventBase
  attr_accessor :garden
  attr_accessor :delta

  def initialize(garden, delta)
    @garden = garden
    @delta = delta
  end

  def print
    puts "ObjectsUpdated"
  end
end

class AddObject < EventBase
  attr_accessor :obj

  def initialize(name, object_info, physics_info)
    @obj = GardenObject.new()
    @obj.name = name
    @obj.object_info = object_info
    @obj.physics_info = physics_info    
  end

  def print
    puts "AddObject"
  end
end

class InternalAddObject < EventBase
  attr_accessor :obj

  def initialize(obj)
    @obj = obj
  end

  def print
    puts "InternalAddObject"
  end
end


class SetGravity < EventBase
  attr_accessor :grav

  def initialize(grav)
    @grav = grav
  end

  def print
    puts "SetGravity"
  end
end

class SetAmbientLight
  attr_accessor :color

  def initialize(color)
    @color = color
  end
end

class KeyPressed < EventBase
  attr_accessor :key

  def initialize(key)
    @key = key
  end

  def print
    puts "key pressed: #{key}"
  end
end

class KeyReleased < EventBase
  attr_accessor :key

  def initialize(key)
    @key = key
  end

  def print
    puts "key released: #{key}"
  end
end

class MousePressed < EventBase
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

class MouseReleased < EventBase
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


class MouseMoved < EventBase
  attr_accessor :event

  def initialize(ois_event)
    @event = ois_event
  end

  def print
    puts "mouse moved"
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

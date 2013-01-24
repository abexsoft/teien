require "teien/garden_base.rb"

module Teien

class ProxyGarden < GardenBase
  def initialize(event_router)
    super(event_router)
  end

  # EventRouter handler
  def setup()
    @physics.setup(self)
    return true
  end

  # EventRouter handler
  def update(delta)
    @physics.update(delta)
    @actors.each_value {|actor|
      actor.update(delta)
    }
    return !@quit
  end

  # EventRouter handler
  def receive_event(event, from)
    case event
    when Event::SyncEnv
#      puts "SyncEnv"
      set_gravity(event.gravity)
      set_ambient_light(event.ambient_light_color)
      set_sky_dome(event.sky_dome.enable, event.sky_dome.materialName)
    when Event::SyncObject
      if @objects[event.name]
#        puts "sync"
        sync_object_with_event(event, @objects[event.name])
      else
#        puts "add"
        create_object_from_event(event)
      end
    end
  end

  def create_object_from_event(event)
    obj = create_object(event.name, event.object_info, event.physics_info)
    obj.set_position(event.pos)
    obj.set_linear_velocity(event.linear_vel)
    obj.set_angular_velocity(event.angular_vel)
    obj.set_rotation(event.quat)
    obj.set_acceleration(event.accel)
#    obj.animation_info = event.animation_info
  end

  def sync_object_with_event(event, obj)
    obj.set_position_with_interpolation(event.pos)
    obj.set_linear_velocity(event.linear_vel)
#    obj.set_linear_velocity_with_interpolation(event.linear_vel)
#    obj.set_angular_velocity(event.angular_vel)
    obj.set_angular_velocity_with_interpolation(event.angular_vel)
    obj.set_rotation(event.quat)
    obj.set_acceleration(event.accel)
 #   obj.animation_info = event.animation_info
  end

  # called by Garden class.
  # clear all managers.
  def finalize()
    @physics.finalize()
    @objects = {}
  end
end

end

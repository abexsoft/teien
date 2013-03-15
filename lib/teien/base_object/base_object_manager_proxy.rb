require "teien/base_object/base_object_manager_base"
require "teien/core/network.rb"
require "teien/base_object/base_object_event.rb"

module Teien

class BaseObjectManagerProxy < BaseObjectManagerBase
  def initialize()
    super()
    @quit = false
  end

  # EventRouter handler
  def setup()
  end

  # EventRouter handler
  def update(delta)
    @physics.update(delta)
    return !@quit
  end

  # EventRouter handler
  def receive_event(event, from)

    # There was a case which this manager gets a new sync packet 
    # after finalizing.
    return if @quit
      
    case event
    when Event::BaseObject::SyncEnv
      set_gravity(event.gravity)
      set_ambient_light(event.ambient_light_color)
      set_sky_dome(event.sky_dome.enable, event.sky_dome.materialName)
    when Event::BaseObject::SyncObject
      if @objects[event.name]
        sync_object_with_event(event, @objects[event.name])
      else
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
    obj.attached_objects  = event.attached_objects
  end

  def sync_object_with_event(event, obj)
    obj.set_position_with_interpolation(event.pos)
    obj.set_linear_velocity(event.linear_vel)
#    obj.set_linear_velocity_with_interpolation(event.linear_vel)
#    obj.set_angular_velocity(event.angular_vel)
    obj.set_angular_velocity_with_interpolation(event.angular_vel)
    obj.set_rotation(event.quat)
    obj.set_acceleration(event.accel)
    obj.attached_objects  = event.attached_objects
  end

  # called by Garden class.
  # clear all managers.
  def finalize()
    @physics.finalize()
    @objects = {}
    @quit = true
  end
end

end

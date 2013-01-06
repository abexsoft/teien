require "teien/garden_base.rb"

module Teien

class ProxyGarden < GardenBase
  attr_accessor :view
  attr_accessor :ui

  def initialize()
    super
  end

  def set_window_title(title)
    @view.window_title = title
  end

  #
  # mainloop
  #
  def run(ip = nil, port = 11922)
    return false unless setup()

    EM.run do
      EM.add_periodic_timer(0) do
        @last_time = Time.now.to_f if @last_time == 0

        now_time = Time.now.to_f
        delta = now_time - @last_time
        @last_time = now_time

        unless update(delta)
          EM.stop
          self.finalize()
        end
      end

      Signal.trap("INT")  { EM.stop; self.finalize() }
      Signal.trap("TERM") { EM.stop; self.finalize() }

      if (ip)
        EM.connect(ip, port, Network, self)
      end
    end
  end    

  def setup()
    @physics.setup(self)
    notify(:setup, self)
    return true
  end

  def update(delta)
    @physics.update(delta)
    @actors.each_value {|actor|
      actor.update(delta)
    }
    notify(:update, delta)
    return !@quit
  end

  def receive_event(event, from)
    case event
    when Event::SyncEnv
      puts "SyncEnv"
      set_gravity(event.gravity)
      set_ambient_light(event.ambient_light_color)
      set_sky_dome(event.sky_dome.enable, event.sky_dome.materialName)
    when Event::SyncObject
      if @objects[event.name]
#        puts "sync"
        sync_object_with_event(event, @objects[event.name])
      else
#        puts "add"
#        @object_factory.create_object_from_event(event)
        create_object_from_event(event)
      end

    end
    notify(:receive_event, event, from)    
  end

  def send_event(event, to = nil)
    if (to)
      to.send_object(event)
    else
      Network::send_all(event) if event.forwarding
      notify(:receive_event, event, nil)
    end
  end

  def create_object_from_event(event)
    obj = create_object(event.name, event.object_info, event.physics_info)
    obj.set_position(event.pos)
    obj.set_linear_velocity(event.linear_vel)
    obj.set_angular_velocity(event.angular_vel)
    obj.set_rotation(event.quat)
    obj.set_acceleration(event.accel)
    obj.animation_info = event.animation_info
  end

  def sync_object_with_event(event, obj)
    obj.set_position_with_interpolation(event.pos)
    obj.set_linear_velocity(event.linear_vel)
#    obj.set_linear_velocity_with_interpolation(event.linear_vel)
#    obj.set_angular_velocity(event.angular_vel)
    obj.set_angular_velocity_with_interpolation(event.angular_vel)
    obj.set_rotation(event.quat)
    obj.set_acceleration(event.accel)
    obj.animation_info = event.animation_info
  end

  # called by Garden class.
  # clear all managers.
  def finalize()
    @physics.finalize()
    @objects = {}
  end
end

end

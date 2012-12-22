require "teien/garden_base.rb"
require "teien/object_factory.rb"

module Teien

class Garden < GardenBase
  def initialize(script_klass)
    super
    @object_factory = ObjectFactory.new(self)
    @event_router.register_event_group(Event::ToControllerGroup)
    @event_router.register_event_type(Event::SyncEnv)
    @event_router.register_event_type(Event::SyncObject)
    @event_router.register_event_type(Event::ClientConnected)
    @event_router.register_receiver(Event::ClientConnected, self)

    @sync_timer = 0
  end

  def set_gravity(grav)
    @physics.set_gravity(grav)
    super(grav)
  end

  def set_ambient_light(color)
    super(color)
  end

  def set_sky_dome(enable, materialName, curvature = 10, tiling = 8, distance = 4000)
    super
  end

  def set_event_handler(handler)
  end

=begin
  def create_user_interface()
    #ServerUserInterface.new(@view)
    return nil 
  end
=end

  def setup()
    @physics = Physics.new(self)
    @script = @script_klass.new(self)

    @physics.setup()
    @script.setup()

    return true
  end

  #
  # mainloop
  #
  def run()
    return false unless setup()

    EM.run do
      EM.add_periodic_timer(0) do
        @last_time = Time.now.to_f if @last_time == 0

        now_time = Time.now.to_f
        delta = now_time - @last_time
        @last_time = now_time

        update(delta)
      end

      Signal.trap("INT")  { EM.stop; self.finalize() }
      Signal.trap("TERM") { EM.stop; self.finalize() }
      EM.start_server("0.0.0.0", 10000, ServerNetwork, @event_router)
    end
  end    

  def update(delta)
    return false unless @physics.update(delta)
      
    @objects.each_value {|obj|
      obj.update(delta)
    }

    return false unless @script.update(delta)

    @sync_timer += delta
    if (@sync_timer > 0.5)
      notify_objects()
      @sync_timer = 0
    end
  end

  def receive_event(event)
    case event
    when Event::ClientConnected
      puts "A client is connected!"

      @event_router.notify(Event::SyncEnv.new(@gravity, @ambient_light_color, @sky_dome))      

      notify_objects()
    end
  end

  def notify_objects()
    @objects.each_value { |obj|
      notify_object(obj)
    }
  end

  def notify_object(obj)
    @event_router.notify(Event::SyncObject.new(obj))
  end

  def finalize()
    @physics.finalize()
    @objects = {}
  end

end

end

require "teien/garden_base.rb"
require "teien/proxy_object_factory.rb"

module Teien

class ProxyGarden < GardenBase
  attr_accessor :view
  attr_accessor :ui

  def initialize(script_klass)
    super

    @debug_draw = false
    @object_factory = ProxyObjectFactory.new(self)
    @event_router.register_event_type(Event::SyncEnv)
    @event_router.register_event_type(Event::SyncObject)
    @event_router.register_receiver(Event::SyncEnv, self)
    @event_router.register_receiver(Event::SyncObject, self)
  end

  def set_window_title(title)
    super
    @view.window_title = title
  end

  def set_gravity(grav)
    super
    @physics.set_gravity(grav)
  end

  def set_ambient_light(color)
    super
    @view.scene_mgr.set_ambient_light(color)
  end

  def set_sky_dome(enable, materialName, curvature = 10, tiling = 8, distance = 4000)
    super
    @view.scene_mgr.set_sky_dome(enable, materialName, curvature, tiling, distance)
  end

  def set_debug_draw(bl)
    if (bl)
      @debug_draw = bl
      @debug_drawer = Teienlib::DebugDrawer.new(@view.scene_mgr)
      @physics.dynamics_world.set_debug_drawer(@debug_drawer)
    end      
  end

=begin
  def create_user_interface()
      return 
  end
=end

  def setup()
    @view = View.new(self)
    @physics = Physics.new(self)
    @script = @script_klass.new(self)
    @ui = UserInterface.new(@view)

    if @view.setup()
      @view.start(@script)
      @view.prepare_render_loop()

      @physics.setup()
      @script.setup()

      return true
    end

    return false
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

        unless update(delta)
          EM.stop
          self.finalize()
        end
      end

      Signal.trap("INT")  { EM.stop; self.finalize() }
      Signal.trap("TERM") { EM.stop; self.finalize() }

      EM.connect('0.0.0.0', 10000, ClientNetwork, @event_router)
    end
  end    

  def update(delta)
    @physics.dynamics_world.debug_draw_world() if @debug_draw
    return @view.update(delta)
  end

  # called from view.update()
  # This function is divided from update() by the purpose of an optimization, 
  # which archives to run in parallel with GPU process.
  def update_in_frame_rendering_queued(delta)
    return false unless @physics.update(delta)
      
    @objects.each_value {|obj|
      obj.update(delta)
    }

    return @script.update(delta)
  end

  def receive_event(event)
    case event
    when Event::SyncEnv
      set_gravity(event.gravity)
      set_ambient_light(event.ambient_light_color)
      set_sky_dome(event.sky_dome.enable, event.sky_dome.materialName)
    when Event::SyncObject
      if @objects[event.name]
        puts "There is a object which has the same name."
      else
        @object_factory.create_object_from_event(event)
      end
    end
  end

  def clean_up()
    @physics.finalize()
    @objects = {}
    @view.stop()
  end

  # called by Garden class.
  # clear all managers.
  def finalize()
    puts "finalize() is called"

    @physics.finalize()
    @view.root.save_config()
    @view.finalize()
    @objects = {}
  end
end

end

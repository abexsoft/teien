require "teien/garden_object.rb"
require "teien/light_object.rb"
require "teien/object_factory.rb"
require "teien/view.rb"
#require "teien/server_view.rb"
require "teien/physics.rb"
require "teien/user_interface.rb"
#require "teien/server_user_interface.rb"

module Teien

# This is a top object of 3D world.
class Garden
  attr_accessor :view
  attr_accessor :physics
  attr_accessor :resources_cfg
  attr_accessor :plugins_cfg
  attr_accessor :objects
  attr_accessor :object_factory
  attr_accessor :is_server

  #
  # _script_klass_:: : set a user define class.
  # 
  def initialize(script_klass)
    @view = nil
    @physics = nil
    @script_klass = script_klass

    @resources_cfg = nil
    @plugins_cfg = nil
    @objects = {}
    @object_num = 0

    @object_factory = ObjectFactory.new(self)

    @is_server = false
    @debug_draw = false
    @quit = false
  end

  #
  # set a title name on the window title bar.
  #
  # _title_ :: : set a name(String).
  #
  def set_window_title(title)
    @view.window_title = title unless @is_server
  end
  
  #
  # set the gravity of the world.
  #
  # _grav_ :: : set a vector(Vector3D) as the gravity.
  #
  def set_gravity(grav)
    @physics.set_gravity(grav)
  end

  #
  # set the ambient light of the world.
  #
  # _color_:: : set a color(Color).
  #
  def set_ambient_light(color)
    @view.scene_mgr.set_ambient_light(color)
  end

  def set_sky_dome(enable, materialName, curvature = 10, tiling = 8, distance = 4000)
    @view.scene_mgr.set_sky_dome(enable, materialName, curvature, tiling, distance)
  end

  def set_debug_draw(bl)
    if (bl)
      @debug_draw = bl
      @debug_drawer = Teienlib::DebugDrawer.new(@view.scene_mgr)
      @physics.dynamicsWorld.set_debug_drawer(@debug_drawer)
    end      
  end

  def create_user_interface()
    if @is_server
      return ServerUserInterface.new(@view)
    else
      return UserInterface.new(@view)
    end
  end

  def create_object(name, objectInfo, physicsInfo)
    return @object_factory.create_object(name, objectInfo, physicsInfo)
  end

  def create_light(name)
    return LightObject.new(self, name)
  end

  def add_object(obj, collision_filter = nil)
    if (@objects[obj.name] == nil)
      if (obj.rigid_body != nil)
        if (collision_filter)
          @physics.add_rigid_body(obj.rigid_body, collision_filter) 
        else
          @physics.add_rigid_body(obj.rigid_body) 
        end
      end
      @objects[obj.name] = obj
      obj.id = @object_num
      @object_num += 1
    else
      raise RuntimeError, "There is a object with the same name (#{obj.name})"
    end
  end

  def check_collision(objectA, objectB)
    result = @physics.contact_pair_test(objectA.rigid_body, objectB.rigid_body)
    return result.isCollided
  end

  def setup()
    if @is_server
      @view = ServerView.new(self)
    else
      @view = View.new(self)
    end

    @physics = Physics.new(self)
    @script = @script_klass.new(self)

    if @view.setup()
      @view.start(@script)
      @view.prepare_render_loop()

      @physics.setup()
      @script.setup()

      return true
    else
      return false
    end
  end

  #
  # mainloop
  #
  def run()
    return false unless setup()

    last_time = Time.now.to_f
    while !@quit
      now_time = Time.now.to_f
      delta = now_time - last_time
      last_time = now_time
      break unless update(delta)
    end
    
    finalize()

    return true
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

  def clean_up()
    @physics.finalize()
    @objects = {}
    @view.stop()
  end

  # called by Garden class.
  # clear all managers.
  def finalize()
    @physics.finalize()
    @view.root.save_config()
    @view.finalize()
    @objects = {}
  end
  

  # quit the current running garden.
  def quit()
    @quit = true
  end
end

end # module 

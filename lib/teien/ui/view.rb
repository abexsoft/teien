require 'teien/ui/ui_listener'
require "teien/ui/view_object_factory.rb"
require "teien/core/dispatcher.rb"

require_relative "std_objects/light_object_info"
require_relative "std_objects/floor_object_info"
require_relative "std_objects/mesh_bb_object_info"
require_relative "std_objects/mesh_object_info"
require_relative "std_objects/box_object_info"
require_relative "std_objects/sphere_object_info"
require_relative "std_objects/capsule_object_info"
require_relative "std_objects/cone_object_info"
require_relative "std_objects/cylinder_object_info"

module Teien

class View < Ogre::FrameListener
  include Dispatcher  

  attr_accessor :root
  attr_accessor :camera
  attr_accessor :window
  attr_accessor :mouse
  attr_accessor :keyboard
  attr_accessor :scene_mgr
  attr_accessor :tray_mgr
  attr_accessor :window_title
  attr_accessor :objects

  def initialize()
    super()

    @adjustFlag = false
    @root = nil
    @camera = nil
    @window = nil
    @mouse = nil
    @keyboard = nil
    @scene_mgr = nil
    @tray_mgr = nil
    @inputManager = nil
    @window_title = ""
    @objects = Hash.new
  end

  def setup(base_object_manager)
    puts "view setup"
    @base_object_manager = base_object_manager
    @plugins_cfg   = @base_object_manager.plugins_cfg ? @base_object_manager.plugins_cfg : "config/plugins.cfg"
    @resources_cfg = @base_object_manager.resources_cfg ? @base_object_manager.resources_cfg : "config/resources.cfg"

    @root = Ogre::Root.new("")
    load_plugins()

    if File.exist?("ogre.cfg")
      return false unless (@root.restore_config())
    else
      return false unless (@root.show_config_dialog())
    end

    @window = @root.initialise(true, @window_title)
    
    init_resources()
    init_managers()

    start()
    prepare_render_loop()

    return true
  end

  def load_plugins
    puts "PluginsCfgFile: #{@plugins_cfg}"
    cfg = Ogre::ConfigFile.new
    cfg.load(@plugins_cfg)

    pluginDir = cfg.get_setting("PluginFolder")
    pluginDir += "/" if (pluginDir.length > 0) && (pluginDir[-1] != '/') 

    cfg.each_settings {|secName, keyName, valueName|
      fullPath = pluginDir + valueName
      if @base_object_manager.resources_cfg
        fullPath.sub!("<ConfigFileFolder>", File.dirname(@base_object_manager.plugins_cfg)) 
      end
      fullPath.sub!("<SystemPluginFolder>", Ruby::Ogre::get_plugin_folder)
      @root.load_plugin(fullPath) if (keyName == "Plugin")
    }
  end

  def init_resources
    puts "ResourcesCfgFile: #{@resources_cfg}"
    # Load resource paths from config file
    cfg = Ogre::ConfigFile.new
    cfg.load(@resources_cfg)

    resourceDir = cfg.get_setting("ResourceFolder")
    resourceDir += "/" if (resourceDir.length > 0) && (resourceDir[-1] != '/')

    cfg.each_settings {|secName, keyName, valueName|
      next if (keyName == "ResourceFolder")

      fullPath = resourceDir + valueName
      if @base_object_manager.resources_cfg
        fullPath.sub!("<ConfigFileFolder>", File.dirname(@base_object_manager.resources_cfg)) 
      end
      fullPath.sub!("<SystemResourceFolder>", Ruby::Ogre::get_resource_folder)

      Ogre::ResourceGroupManager::get_singleton().add_resource_location(fullPath, 
                                                                        keyName, 
                                                                        secName)
    }
  end

  def init_managers
    @root.add_frame_listener(self)

    # initialize InputManager
    windowHnd = Ogre::Intp.new
    @window.get_custom_attribute("WINDOW", windowHnd)
    windowHndStr = sprintf("%d", windowHnd.value())
    pl = Ois::ParamList.new
    pl["WINDOW"] = windowHndStr

    # initialize input manager
    @inputManager = Ois::InputManager::create_input_system(pl)
    @keyboard = @inputManager.create_input_object(Ois::OISKeyboard, true).to_keyboard()
    @mouse = @inputManager.create_input_object(Ois::OISMouse, true).to_mouse()

    # initialize trayManager
    Ogre::ResourceGroupManager::get_singleton().initialise_resource_group("Essential")
    @tray_mgr = Ogrebites::SdkTrayManager.new("Base", @window, @mouse);
    ms = @mouse.get_mouse_state()
    ms.width = @window.get_width()
    ms.height = @window.get_height()
  end

  def start()
    # initialize scene_mgr
    @scene_mgr = @root.create_scene_manager(Ogre::ST_GENERIC)
    @scene_mgr.set_shadow_technique(Ogre::SHADOWTYPE_STENCIL_ADDITIVE)

    # initialize a camera
    @camera = @scene_mgr.create_camera("FixCamera")
    # Create one viewport, entire window
    @vp = @window.add_viewport(@camera)
    @vp.set_background_colour(Ogre::ColourValue.new(0, 0, 0))
    # Alter the camera aspect ratio to match the viewport
    @camera.set_aspect_ratio(Float(@vp.get_actual_width()) / Float(@vp.get_actual_height()));

    # set listeners.
    @keyListener = KeyListener.new(self)
    @keyboard.set_event_callback(@keyListener)
    @mouseListener = MouseListener.new(self)
    @mouse.set_event_callback(@mouseListener)
    @trayListener = TrayListener.new(self)
    @tray_mgr.set_listener(@trayListener)

    # load resources into ResourceGroupManager.
    @tray_mgr.show_loading_bar(1, 0)
    Ogre::ResourceGroupManager::get_singleton().initialise_resource_group("General")
    @tray_mgr.hide_loading_bar()
    Ogre::TextureManager::get_singleton().set_default_num_mipmaps(5)
  end

  def prepare_render_loop
    @root.get_render_system()._init_render_targets()
    @root.clear_event_times()
  end

  def stop
    @scene_mgr.clear_scene() if (@scene_mgr != nil)
    @root.destroy_scene_manager(@scene_mgr) if (@scene_mgr != nil)
    @scene_mgr = nil
    @window.remove_all_viewports()
    @tray_mgr.destroy_all_widgets()
  end

  def finalize
    stop()
    if (@inputManger != nil)
      @inputManager.destroy_input_object(@keyboard)
      @inputManager.destroy_input_object(@mouse)
      @inputManager = nil
    end
    @root.shutdown()
  end

  def set_ambient_light(color)
    @scene_mgr.set_ambient_light(color)
  end

  def create_object(obj)
    view_object = ViewObjectFactory::create_object(obj, self)

    obj.register_receiver(view_object)
    view_object.object = obj

    @objects[obj.name] = view_object if view_object
  end

  # Takes a screen shot.
  def take_screen_shot(name)
    @window.write_contents_to_timestamped_file(name + "_", ".png")
  end

  # Shows the animation infomation of the entity.
  def show_all_animation(entity)
    puts "Animations:"
    animSet = entity.get_all_animation_states()
    animSet.each_animation_state() {|state|
      puts "name: #{state.get_animation_name()}, len: #{state.get_length()}"
    }
  end

  # Called by the main loop periodically
  def update(delta)
    Ogre::WindowEventUtilities.message_pump()
    return @root.render_one_frame(delta)
  end

  # Called through @root.render_one_frame(delta).
  def frame_rendering_queued(evt)
    @keyboard.capture()
    @mouse.capture()

    animation_manager = Teien::get_component("animation_manager")
    @objects.each_value {|obj|
      if obj.object.attached_objects.length > 0
        obj.update_attached_objects(self)
      end

      animation = animation_manager.animations[obj.object.name]
      obj.update_animation(evt.timeSinceLastFrame, animation) if animation
    }

    @tray_mgr.frame_rendering_queued(evt)
    if (@adjustFlag != true)
      @tray_mgr.adjust_trays() # fix a caption invisible bug.
      @adjustFlag = true
    end

    return true
  end

  def key_pressed(keyEvent)
    notify(:key_pressed, keyEvent)
    return true
  end

  def key_released(keyEvent)
    notify(:key_released, keyEvent)
    return true
  end

  def mouse_moved(evt)
    return true if @tray_mgr.inject_mouse_move(evt)
    notify(:mouse_moved, evt)
    return true
  end
  
  def mouse_pressed(mouseEvent, mouseButtonID)
    return true if @tray_mgr.inject_mouse_down(mouseEvent, mouseButtonID)
    notify(:mouse_pressed, mouseEvent, mouseButtonID)
    return true 
  end
  
  def mouse_released(mouseEvent, mouseButtonID)
    return true if @tray_mgr.inject_mouse_up(mouseEvent, mouseButtonID)
    notify(:mouse_released, mouseEvent, mouseButtonID)
    return true 
  end
end

end # module 



=begin
  def create_scene_node(parent = nil)
    if (parent == nil)
      scene_node = @scene_mgr.get_root_scene_node().create_child_scene_node()
    else
      scene_node = parent.create_child_scene_node()
    end
    return scene_node
  end
=end


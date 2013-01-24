require 'teien/ui_listener'
require "teien/view_object_factory.rb"
require "teien/dispatcher.rb"

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
  end

  def setup(garden)
    puts "view setup"
    @garden = garden
    @plugins_cfg   = @garden.plugins_cfg ? @garden.plugins_cfg : "config/plugins.cfg"
    @resources_cfg = @garden.resources_cfg ? @garden.resources_cfg : "config/resources.cfg"

    @root = Ogre::Root.new("")
    load_plugins()

#    return false unless (@root.restoreConfig())
    return false unless (@root.show_config_dialog())

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
      fullPath.sub!("<ConfigFileFolder>", File.dirname(@garden.plugins_cfg)) if @garden.resources_cfg
      fullPath.sub!("<SystemPluginFolder>", OgreConfig::get_plugin_folder)
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
      if @garden.resources_cfg
        fullPath.sub!("<ConfigFileFolder>", File.dirname(@garden.resources_cfg)) 
      end
      fullPath.sub!("<SystemResourceFolder>", OgreConfig::get_resource_folder)

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

  def add_view_object(obj)
    obj.view_object = ViewObjectFactory::create_object(obj, self)
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

  # Called through @root.renderOneFrame(delta).
  def frame_rendering_queued(evt)
    @keyboard.capture()
    @mouse.capture()

    @garden.objects.each_value {|obj|
      if obj.object_info.use_view
        obj.view_object.update_animation(evt.timeSinceLastFrame, obj.animation_info)
      end
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


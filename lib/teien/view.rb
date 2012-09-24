require 'teien/ui_listener'

module Teien

class View < Ogre::FrameListener
  attr_accessor :root
  attr_accessor :camera
  attr_accessor :window
  attr_accessor :mouse
  attr_accessor :keyboard
  attr_accessor :scene_mgr
  attr_accessor :tray_mgr
  attr_accessor :window_title


  def initialize(garden)
    super()
    @garden = garden
    @adjustFlag = false
    @root = nil
    @camera = nil
    @window = nil
    @mouse = nil
    @keyboard = nil
    @controller = nil
    @scene_mgr = nil
    @tray_mgr = nil
    @inputManager = nil
    @window_title = ""
  end

  def set_controller(controller)
    @controller = controller
  end

  def setup
    @plugins_cfg   = @garden.plugins_cfg ? @garden.plugins_cfg : "plugins.cfg"
    @resources_cfg = @garden.resources_cfg ? @garden.resources_cfg : "resources.cfg"

    @root = Ogre::Root.new("")
    load_plugins()

#    return false unless (@root.restoreConfig())
    return false unless (@root.showConfigDialog())

    @window = @root.initialise(true, @window_title)
    
    init_resources()
    init_managers()

    return true
  end

  def load_plugins
    puts "PluginsCfgFile: #{@plugins_cfg}"
    cfg = Ogre::ConfigFile.new
    cfg.load(@plugins_cfg)

    pluginDir = cfg.getSetting("PluginFolder")
    pluginDir += "/" if (pluginDir.length > 0) && (pluginDir[-1] != '/') 

    cfg.each_Settings {|secName, keyName, valueName|
      fullPath = pluginDir + valueName
      fullPath.sub!("<ConfigFileFolder>", File.dirname(@garden.plugins_cfg)) if @garden.resources_cfg
      fullPath.sub!("<SystemPluginFolder>", OgreConfig::getPluginFolder)
      @root.loadPlugin(fullPath) if (keyName == "Plugin")
    }
  end

  def init_resources
    puts "ResourcesCfgFile: #{@resources_cfg}"
    # Load resource paths from config file
    cfg = Ogre::ConfigFile.new
    cfg.load(@resources_cfg)

    resourceDir = cfg.getSetting("ResourceFolder")
    resourceDir += "/" if (resourceDir.length > 0) && (resourceDir[-1] != '/')

    cfg.each_Settings {|secName, keyName, valueName|
      next if (keyName == "ResourceFolder")

      fullPath = resourceDir + valueName
      if @garden.resources_cfg
        fullPath.sub!("<ConfigFileFolder>", File.dirname(@garden.resources_cfg)) 
      end
      fullPath.sub!("<SystemResourceFolder>", OgreConfig::getResourceFolder)

      Ogre::ResourceGroupManager::getSingleton().addResourceLocation(fullPath, 
                                                                     keyName, 
                                                                     secName)
    }
  end

  def init_managers
    @root.addFrameListener(self)

    # initialize InputManager
    windowHnd = Ogre::Intp.new
    @window.getCustomAttribute("WINDOW", windowHnd)
    windowHndStr = sprintf("%d", windowHnd.value())
    pl = OIS::ParamList.new
    pl["WINDOW"] = windowHndStr

    # initialize input manager
    @inputManager = OIS::InputManager::createInputSystem(pl)
    @keyboard = @inputManager.createInputObject(OIS::OISKeyboard, true).toKeyboard()
    @mouse = @inputManager.createInputObject(OIS::OISMouse, true).toMouse()

    # initialize trayManager
    Ogre::ResourceGroupManager::getSingleton().initialiseResourceGroup("Essential")
    @tray_mgr = OgreBites::SdkTrayManager.new("Base", @window, @mouse);
    ms = @mouse.getMouseState()
    ms.width = @window.getWidth()
    ms.height = @window.getHeight()
  end

  def start(script)
    @script = script

    # initialize scene_mgr
    @scene_mgr = @root.createSceneManager(Ogre::ST_GENERIC)
    @scene_mgr.setShadowTechnique(Ogre::SHADOWTYPE_STENCIL_ADDITIVE)

    # initialize a camera
    @camera = @scene_mgr.createCamera("FixCamera")
    # Create one viewport, entire window
    @vp = @window.addViewport(@camera);
    @vp.setBackgroundColour(Ogre::ColourValue.new(0, 0, 0));
    # Alter the camera aspect ratio to match the viewport
    @camera.setAspectRatio(Float(@vp.getActualWidth()) / Float(@vp.getActualHeight()));

    # set listeners.
    @keyListener = KeyListener.new(self)
    @keyboard.setEventCallback(@keyListener)
    @mouseListener = MouseListener.new(self)
    @mouse.setEventCallback(@mouseListener)
    @trayListener = TrayListener.new(@script)
    @tray_mgr.setListener(@trayListener)

    # load resources into ResourceGroupManager.
    @tray_mgr.showLoadingBar(1, 0)
    Ogre::ResourceGroupManager::getSingleton().initialiseResourceGroup("General")
    @tray_mgr.hideLoadingBar()
    Ogre::TextureManager::getSingleton().setDefaultNumMipmaps(5)
  end

  def prepare_render_loop
    @root.getRenderSystem()._initRenderTargets()
    @root.clearEventTimes()
  end

  def stop
    @scene_mgr.clearScene() if (@scene_mgr != nil)
    @root.destroySceneManager(@scene_mgr) if (@scene_mgr != nil)
    @scene_mgr = nil
    @window.removeAllViewports()
    @tray_mgr.destroyAllWidgets()
  end

  def finalize
    stop()
    if (@inputManger != nil)
      @inputManager.destroyInputObject(@keyboard)
      @inputManager.destroyInputObject(@mouse)
      @inputManager = nil
    end
    @root.shutdown()
  end

  def create_scene_node(parent = nil)
    if (parent == nil)
      scene_node = @scene_mgr.getRootSceneNode().createChildSceneNode()
    else
      scene_node = parent.createChildSceneNode()
    end
    return scene_node
  end

  # Takes a screen shot.
  def take_screen_shot(name)
    @window.writeContentsToTimestampedFile(name + "_", ".png")
  end

  # Shows the animation infomation of the entity.
  def show_all_animation(entity)
    puts "Animations:"
    animSet = entity.getAllAnimationStates()
    animSet.each_AnimationState() {|state|
      puts "name: #{state.getAnimationName()}, len: #{state.getLength()}"
    }
  end

  # Called by the main loop periodically
  def update(delta)
    Ogre::WindowEventUtilities.messagePump()
    return @root.renderOneFrame(delta)
  end

  # Called through @root.renderOneFrame(delta).
  def frameRenderingQueued(evt)
    @keyboard.capture()
    @mouse.capture()
    @controller.update(evt.timeSinceLastFrame) if @controller

    @tray_mgr.frameRenderingQueued(evt)
    if (@adjustFlag != true)
      @tray_mgr.adjustTrays() # fix a caption invisible bug.
      @adjustFlag = true
    end

    return @garden.updateInFrameRenderingQueued(evt.timeSinceLastFrame)
  end

  def key_pressed(keyEvent)
    return true if @controller == nil
    return @controller.key_pressed(keyEvent)
  end

  def key_released(keyEvent)
    return true if @controller == nil
    return @controller.key_released(keyEvent)
  end

  def mouse_moved(evt)
    return true if @tray_mgr.injectMouseMove(evt)
    return true if @controller == nil      
    return @controller.mouse_moved(evt)
  end
  
  def mouse_pressed(mouseEvent, mouseButtonID)
    return true if @tray_mgr.injectMouseDown(mouseEvent, mouseButtonID)
    return true if @controller == nil      
    return @controller.mouse_pressed(mouseEvent, mouseButtonID)
  end
  
  def mouse_released(mouseEvent, mouseButtonID)
    return true if @tray_mgr.injectMouseUp(mouseEvent, mouseButtonID)
    return true if @controller == nil      
    return @controller.mouse_released(mouseEvent, mouseButtonID)
  end

end

end # module 

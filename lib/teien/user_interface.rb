require 'teien/camera'
require 'teien/view'
require "teien/dispatcher.rb"

module Teien

class UserInterface
  include Dispatcher  

  attr_accessor :garden
  attr_accessor :debug_draw

  def initialize(garden)
    super()

    @garden = garden
    @garden.register_receiver(self)

    @view = View.new()
    @camera = nil

    @debug_draw = false
  end

  def set_window_title(title)
    @view.window_title = title
  end

  def set_debug_draw(bl)
    @debug_draw = bl
    if (bl)
      @debug_drawer = Teienlib::DebugDrawer.new(@view.scene_mgr)
      @garden.physics.dynamics_world.set_debug_drawer(@debug_drawer)
    end      
  end

  def get_camera()
    @camera = Camera.new(@view.camera) if @camera == nil
    return @camera
  end

  def show_frame_stats(placement)
    @view.tray_mgr.show_frame_stats(placement)
  end

  def show_logo(placement)
    @view.tray_mgr.show_logo(placement)
  end

  def show_cursor()
    @view.tray_mgr.show_cursor()
  end

  def hide_cursor()
    @view.tray_mgr.hide_cursor()
  end

  def register_receiver(recv)
    super
    @view.register_receiver(recv)
  end

  # called as a receiver by a dispatcher.

  #
  # By Garden/GardenBase
  #

  def set_ambient_light(color)
    @view.set_ambient_light(color)
  end

  def set_sky_dome(enable, materialName, curvature = 10, tiling = 8, distance = 4000)
    @view.scene_mgr.set_sky_dome(enable, materialName, curvature, tiling, distance)
  end

  def setup(garden)
    @view.setup(garden)
    notify(:setup, garden)
  end

  def create_object(obj)
    @view.add_view_object(obj)
  end

  def update(delta)
    @garden.physics.dynamics_world.debug_draw_world() if @debug_draw
    @view.update(delta)
    notify(:update, delta)
  end
end

class UI < UserInterface
  # Layout
  TL_BOTTOMLEFT =  Ogrebites::TL_BOTTOMLEFT
  TL_BOTTOMRIGHT = Ogrebites::TL_BOTTOMRIGHT

  # Keyboard
  KC_UNASSIGNED  =   Ois::KC_UNASSIGNED  
  KC_ESCAPE      =   Ois::KC_ESCAPE      
  KC_1           =   Ois::KC_1           
  KC_2           =   Ois::KC_2           
  KC_3           =   Ois::KC_3           
  KC_4           =   Ois::KC_4           
  KC_5           =   Ois::KC_5           
  KC_6           =   Ois::KC_6           
  KC_7           =   Ois::KC_7           
  KC_8           =   Ois::KC_8           
  KC_9           =   Ois::KC_9           
  KC_0           =   Ois::KC_0           
  KC_MINUS       =   Ois::KC_MINUS       
  KC_EQUALS      =   Ois::KC_EQUALS      
  KC_BACK        =   Ois::KC_BACK        
  KC_TAB         =   Ois::KC_TAB         
  KC_Q           =   Ois::KC_Q           
  KC_W           =   Ois::KC_W           
  KC_E           =   Ois::KC_E           
  KC_R           =   Ois::KC_R           
  KC_T           =   Ois::KC_T           
  KC_Y           =   Ois::KC_Y           
  KC_U           =   Ois::KC_U           
  KC_I           =   Ois::KC_I           
  KC_O           =   Ois::KC_O           
  KC_P           =   Ois::KC_P           
  KC_LBRACKET    =   Ois::KC_LBRACKET    
  KC_RBRACKET    =   Ois::KC_RBRACKET    
  KC_RETURN      =   Ois::KC_RETURN      
  KC_LCONTROL    =   Ois::KC_LCONTROL    
  KC_A           =   Ois::KC_A           
  KC_S           =   Ois::KC_S           
  KC_D           =   Ois::KC_D           
  KC_F           =   Ois::KC_F           
  KC_G           =   Ois::KC_G           
  KC_H           =   Ois::KC_H           
  KC_J           =   Ois::KC_J           
  KC_K           =   Ois::KC_K           
  KC_L           =   Ois::KC_L           
  KC_SEMICOLON   =   Ois::KC_SEMICOLON   
  KC_APOSTROPHE  =   Ois::KC_APOSTROPHE  
  KC_GRAVE       =   Ois::KC_GRAVE       
  KC_LSHIFT      =   Ois::KC_LSHIFT      
  KC_BACKSLASH   =   Ois::KC_BACKSLASH   
  KC_Z           =   Ois::KC_Z           
  KC_X           =   Ois::KC_X           
  KC_C           =   Ois::KC_C           
  KC_V           =   Ois::KC_V           
  KC_B           =   Ois::KC_B           
  KC_N           =   Ois::KC_N           
  KC_M           =   Ois::KC_M           
  KC_COMMA       =   Ois::KC_COMMA       
  KC_PERIOD      =   Ois::KC_PERIOD      
  KC_SLASH       =   Ois::KC_SLASH       
  KC_RSHIFT      =   Ois::KC_RSHIFT      
  KC_MULTIPLY    =   Ois::KC_MULTIPLY    
  KC_LMENU       =   Ois::KC_LMENU       
  KC_SPACE       =   Ois::KC_SPACE       
  KC_CAPITAL     =   Ois::KC_CAPITAL     
  KC_F1          =   Ois::KC_F1          
  KC_F2          =   Ois::KC_F2          
  KC_F3          =   Ois::KC_F3          
  KC_F4          =   Ois::KC_F4          
  KC_F5          =   Ois::KC_F5          
  KC_F6          =   Ois::KC_F6          
  KC_F7          =   Ois::KC_F7          
  KC_F8          =   Ois::KC_F8          
  KC_F9          =   Ois::KC_F9          
  KC_F10         =   Ois::KC_F10         
  KC_NUMLOCK     =   Ois::KC_NUMLOCK     
  KC_SCROLL      =   Ois::KC_SCROLL      
  KC_NUMPAD7     =   Ois::KC_NUMPAD7     
  KC_NUMPAD8     =   Ois::KC_NUMPAD8     
  KC_NUMPAD9     =   Ois::KC_NUMPAD9     
  KC_SUBTRACT    =   Ois::KC_SUBTRACT    
  KC_NUMPAD4     =   Ois::KC_NUMPAD4     
  KC_NUMPAD5     =   Ois::KC_NUMPAD5     
  KC_NUMPAD6     =   Ois::KC_NUMPAD6     
  KC_ADD         =   Ois::KC_ADD         
  KC_NUMPAD1     =   Ois::KC_NUMPAD1     
  KC_NUMPAD2     =   Ois::KC_NUMPAD2     
  KC_NUMPAD3     =   Ois::KC_NUMPAD3     
  KC_NUMPAD0     =   Ois::KC_NUMPAD0     
  KC_DECIMAL     =   Ois::KC_DECIMAL     
  KC_OEM_102     =   Ois::KC_OEM_102     
  KC_F11         =   Ois::KC_F11         
  KC_F12         =   Ois::KC_F12         
  KC_F13         =   Ois::KC_F13         
  KC_F14         =   Ois::KC_F14         
  KC_F15         =   Ois::KC_F15         
  KC_KANA        =   Ois::KC_KANA        
  KC_ABNT_C1     =   Ois::KC_ABNT_C1     
  KC_CONVERT     =   Ois::KC_CONVERT     
  KC_NOCONVERT   =   Ois::KC_NOCONVERT   
  KC_YEN         =   Ois::KC_YEN         
  KC_ABNT_C2     =   Ois::KC_ABNT_C2     
  KC_NUMPADEQUALS=   Ois::KC_NUMPADEQUALS
  KC_PREVTRACK   =   Ois::KC_PREVTRACK   
  KC_AT          =   Ois::KC_AT          
  KC_COLON       =   Ois::KC_COLON       
  KC_UNDERLINE   =   Ois::KC_UNDERLINE   
  KC_KANJI       =   Ois::KC_KANJI       
  KC_STOP        =   Ois::KC_STOP        
  KC_AX          =   Ois::KC_AX          
  KC_UNLABELED   =   Ois::KC_UNLABELED   
  KC_NEXTTRACK   =   Ois::KC_NEXTTRACK   
  KC_NUMPADENTER =   Ois::KC_NUMPADENTER 
  KC_RCONTROL    =   Ois::KC_RCONTROL    
  KC_MUTE        =   Ois::KC_MUTE        
  KC_CALCULATOR  =   Ois::KC_CALCULATOR  
  KC_PLAYPAUSE   =   Ois::KC_PLAYPAUSE   
  KC_MEDIASTOP   =   Ois::KC_MEDIASTOP   
  KC_VOLUMEDOWN  =   Ois::KC_VOLUMEDOWN  
  KC_VOLUMEUP    =   Ois::KC_VOLUMEUP    
  KC_WEBHOME     =   Ois::KC_WEBHOME     
  KC_NUMPADCOMMA =   Ois::KC_NUMPADCOMMA 
  KC_DIVIDE      =   Ois::KC_DIVIDE      
  KC_SYSRQ       =   Ois::KC_SYSRQ       
  KC_RMENU       =   Ois::KC_RMENU       
  KC_PAUSE       =   Ois::KC_PAUSE       
  KC_HOME        =   Ois::KC_HOME        
  KC_UP          =   Ois::KC_UP          
  KC_PGUP        =   Ois::KC_PGUP        
  KC_LEFT        =   Ois::KC_LEFT        
  KC_RIGHT       =   Ois::KC_RIGHT       
  KC_END         =   Ois::KC_END         
  KC_DOWN        =   Ois::KC_DOWN        
  KC_PGDOWN      =   Ois::KC_PGDOWN      
  KC_INSERT      =   Ois::KC_INSERT      
  KC_DELETE      =   Ois::KC_DELETE      
  KC_LWIN        =   Ois::KC_LWIN        
  KC_RWIN        =   Ois::KC_RWIN        
  KC_APPS        =   Ois::KC_APPS        
  KC_POWER       =   Ois::KC_POWER       
  KC_SLEEP       =   Ois::KC_SLEEP       
  KC_WAKE        =   Ois::KC_WAKE        
  KC_WEBSEARCH   =   Ois::KC_WEBSEARCH   
  KC_WEBFAVORITES=   Ois::KC_WEBFAVORITES
  KC_WEBREFRESH  =   Ois::KC_WEBREFRESH  
  KC_WEBSTOP     =   Ois::KC_WEBSTOP     
  KC_WEBFORWARD  =   Ois::KC_WEBFORWARD  
  KC_WEBBACK     =   Ois::KC_WEBBACK     
  KC_MYCOMPUTER  =   Ois::KC_MYCOMPUTER  
  KC_MAIL        =   Ois::KC_MAIL        
  KC_MEDIASELECT =   Ois::KC_MEDIASELECT 

  # Mouse
  MB_Left    = Ois::MB_Left
  MB_Right   = Ois::MB_Right
  MB_Middle  = Ois::MB_Middle
  MB_Button3 = Ois::MB_Button3 
  MB_Button4 = Ois::MB_Button4	
  MB_Button5 = Ois::MB_Button5 
  MB_Button6 = Ois::MB_Button6	
  MB_Button7 = Ois::MB_Button7
end


end

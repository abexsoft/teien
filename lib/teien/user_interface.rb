require 'teien/camera'

module Teien

class UserInterface
  def initialize(view)
    @view = view
    @camera = Camera.new(view.camera)
  end

  def set_controller(controller)
    @view.set_controller(controller)
  end

  def get_camera()
    return @camera
  end

  def show_frame_stats(placement)
    @view.tray_mgr.showFrameStats(placement)
  end

  def show_logo(placement)
    @view.tray_mgr.showLogo(placement)
  end

  def show_cursor()
    @view.tray_mgr.showCursor()
  end

  def hide_cursor()
    @view.tray_mgr.hideCursor()
  end

end

class UI < UserInterface
  # Layout
  TL_BOTTOMLEFT =  OgreBites::TL_BOTTOMLEFT
  TL_BOTTOMRIGHT = OgreBites::TL_BOTTOMRIGHT

  # Keyboard
  KC_UNASSIGNED  =   OIS::KC_UNASSIGNED  
  KC_ESCAPE      =   OIS::KC_ESCAPE      
  KC_1           =   OIS::KC_1           
  KC_2           =   OIS::KC_2           
  KC_3           =   OIS::KC_3           
  KC_4           =   OIS::KC_4           
  KC_5           =   OIS::KC_5           
  KC_6           =   OIS::KC_6           
  KC_7           =   OIS::KC_7           
  KC_8           =   OIS::KC_8           
  KC_9           =   OIS::KC_9           
  KC_0           =   OIS::KC_0           
  KC_MINUS       =   OIS::KC_MINUS       
  KC_EQUALS      =   OIS::KC_EQUALS      
  KC_BACK        =   OIS::KC_BACK        
  KC_TAB         =   OIS::KC_TAB         
  KC_Q           =   OIS::KC_Q           
  KC_W           =   OIS::KC_W           
  KC_E           =   OIS::KC_E           
  KC_R           =   OIS::KC_R           
  KC_T           =   OIS::KC_T           
  KC_Y           =   OIS::KC_Y           
  KC_U           =   OIS::KC_U           
  KC_I           =   OIS::KC_I           
  KC_O           =   OIS::KC_O           
  KC_P           =   OIS::KC_P           
  KC_LBRACKET    =   OIS::KC_LBRACKET    
  KC_RBRACKET    =   OIS::KC_RBRACKET    
  KC_RETURN      =   OIS::KC_RETURN      
  KC_LCONTROL    =   OIS::KC_LCONTROL    
  KC_A           =   OIS::KC_A           
  KC_S           =   OIS::KC_S           
  KC_D           =   OIS::KC_D           
  KC_F           =   OIS::KC_F           
  KC_G           =   OIS::KC_G           
  KC_H           =   OIS::KC_H           
  KC_J           =   OIS::KC_J           
  KC_K           =   OIS::KC_K           
  KC_L           =   OIS::KC_L           
  KC_SEMICOLON   =   OIS::KC_SEMICOLON   
  KC_APOSTROPHE  =   OIS::KC_APOSTROPHE  
  KC_GRAVE       =   OIS::KC_GRAVE       
  KC_LSHIFT      =   OIS::KC_LSHIFT      
  KC_BACKSLASH   =   OIS::KC_BACKSLASH   
  KC_Z           =   OIS::KC_Z           
  KC_X           =   OIS::KC_X           
  KC_C           =   OIS::KC_C           
  KC_V           =   OIS::KC_V           
  KC_B           =   OIS::KC_B           
  KC_N           =   OIS::KC_N           
  KC_M           =   OIS::KC_M           
  KC_COMMA       =   OIS::KC_COMMA       
  KC_PERIOD      =   OIS::KC_PERIOD      
  KC_SLASH       =   OIS::KC_SLASH       
  KC_RSHIFT      =   OIS::KC_RSHIFT      
  KC_MULTIPLY    =   OIS::KC_MULTIPLY    
  KC_LMENU       =   OIS::KC_LMENU       
  KC_SPACE       =   OIS::KC_SPACE       
  KC_CAPITAL     =   OIS::KC_CAPITAL     
  KC_F1          =   OIS::KC_F1          
  KC_F2          =   OIS::KC_F2          
  KC_F3          =   OIS::KC_F3          
  KC_F4          =   OIS::KC_F4          
  KC_F5          =   OIS::KC_F5          
  KC_F6          =   OIS::KC_F6          
  KC_F7          =   OIS::KC_F7          
  KC_F8          =   OIS::KC_F8          
  KC_F9          =   OIS::KC_F9          
  KC_F10         =   OIS::KC_F10         
  KC_NUMLOCK     =   OIS::KC_NUMLOCK     
  KC_SCROLL      =   OIS::KC_SCROLL      
  KC_NUMPAD7     =   OIS::KC_NUMPAD7     
  KC_NUMPAD8     =   OIS::KC_NUMPAD8     
  KC_NUMPAD9     =   OIS::KC_NUMPAD9     
  KC_SUBTRACT    =   OIS::KC_SUBTRACT    
  KC_NUMPAD4     =   OIS::KC_NUMPAD4     
  KC_NUMPAD5     =   OIS::KC_NUMPAD5     
  KC_NUMPAD6     =   OIS::KC_NUMPAD6     
  KC_ADD         =   OIS::KC_ADD         
  KC_NUMPAD1     =   OIS::KC_NUMPAD1     
  KC_NUMPAD2     =   OIS::KC_NUMPAD2     
  KC_NUMPAD3     =   OIS::KC_NUMPAD3     
  KC_NUMPAD0     =   OIS::KC_NUMPAD0     
  KC_DECIMAL     =   OIS::KC_DECIMAL     
  KC_OEM_102     =   OIS::KC_OEM_102     
  KC_F11         =   OIS::KC_F11         
  KC_F12         =   OIS::KC_F12         
  KC_F13         =   OIS::KC_F13         
  KC_F14         =   OIS::KC_F14         
  KC_F15         =   OIS::KC_F15         
  KC_KANA        =   OIS::KC_KANA        
  KC_ABNT_C1     =   OIS::KC_ABNT_C1     
  KC_CONVERT     =   OIS::KC_CONVERT     
  KC_NOCONVERT   =   OIS::KC_NOCONVERT   
  KC_YEN         =   OIS::KC_YEN         
  KC_ABNT_C2     =   OIS::KC_ABNT_C2     
  KC_NUMPADEQUALS=   OIS::KC_NUMPADEQUALS
  KC_PREVTRACK   =   OIS::KC_PREVTRACK   
  KC_AT          =   OIS::KC_AT          
  KC_COLON       =   OIS::KC_COLON       
  KC_UNDERLINE   =   OIS::KC_UNDERLINE   
  KC_KANJI       =   OIS::KC_KANJI       
  KC_STOP        =   OIS::KC_STOP        
  KC_AX          =   OIS::KC_AX          
  KC_UNLABELED   =   OIS::KC_UNLABELED   
  KC_NEXTTRACK   =   OIS::KC_NEXTTRACK   
  KC_NUMPADENTER =   OIS::KC_NUMPADENTER 
  KC_RCONTROL    =   OIS::KC_RCONTROL    
  KC_MUTE        =   OIS::KC_MUTE        
  KC_CALCULATOR  =   OIS::KC_CALCULATOR  
  KC_PLAYPAUSE   =   OIS::KC_PLAYPAUSE   
  KC_MEDIASTOP   =   OIS::KC_MEDIASTOP   
  KC_VOLUMEDOWN  =   OIS::KC_VOLUMEDOWN  
  KC_VOLUMEUP    =   OIS::KC_VOLUMEUP    
  KC_WEBHOME     =   OIS::KC_WEBHOME     
  KC_NUMPADCOMMA =   OIS::KC_NUMPADCOMMA 
  KC_DIVIDE      =   OIS::KC_DIVIDE      
  KC_SYSRQ       =   OIS::KC_SYSRQ       
  KC_RMENU       =   OIS::KC_RMENU       
  KC_PAUSE       =   OIS::KC_PAUSE       
  KC_HOME        =   OIS::KC_HOME        
  KC_UP          =   OIS::KC_UP          
  KC_PGUP        =   OIS::KC_PGUP        
  KC_LEFT        =   OIS::KC_LEFT        
  KC_RIGHT       =   OIS::KC_RIGHT       
  KC_END         =   OIS::KC_END         
  KC_DOWN        =   OIS::KC_DOWN        
  KC_PGDOWN      =   OIS::KC_PGDOWN      
  KC_INSERT      =   OIS::KC_INSERT      
  KC_DELETE      =   OIS::KC_DELETE      
  KC_LWIN        =   OIS::KC_LWIN        
  KC_RWIN        =   OIS::KC_RWIN        
  KC_APPS        =   OIS::KC_APPS        
  KC_POWER       =   OIS::KC_POWER       
  KC_SLEEP       =   OIS::KC_SLEEP       
  KC_WAKE        =   OIS::KC_WAKE        
  KC_WEBSEARCH   =   OIS::KC_WEBSEARCH   
  KC_WEBFAVORITES=   OIS::KC_WEBFAVORITES
  KC_WEBREFRESH  =   OIS::KC_WEBREFRESH  
  KC_WEBSTOP     =   OIS::KC_WEBSTOP     
  KC_WEBFORWARD  =   OIS::KC_WEBFORWARD  
  KC_WEBBACK     =   OIS::KC_WEBBACK     
  KC_MYCOMPUTER  =   OIS::KC_MYCOMPUTER  
  KC_MAIL        =   OIS::KC_MAIL        
  KC_MEDIASELECT =   OIS::KC_MEDIASELECT 

  # Mouse
  MB_Left    = OIS::MB_Left
  MB_Right   = OIS::MB_Right
  MB_Middle  = OIS::MB_Middle
  MB_Button3 = OIS::MB_Button3 
  MB_Button4 = OIS::MB_Button4	
  MB_Button5 = OIS::MB_Button5 
  MB_Button6 = OIS::MB_Button6	
  MB_Button7 = OIS::MB_Button7
end


end

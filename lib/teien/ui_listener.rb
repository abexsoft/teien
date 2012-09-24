module Teien
  #
  # Key Listener
  #
  class KeyListener < OIS::KeyListener
    def initialize(listener)
      super()
      @listener = listener
    end

    def keyPressed(key_event)
      return @listener.key_pressed(key_event)
    end
    
    def keyReleased(key_event)
      return @listener.key_released(key_event)
    end
  end

  #
  # Mouse Listener
  #
  class MouseListener < OIS::MouseListener
    def initialize(listener)
      super()
      @listener = listener
    end

    def mouseMoved(evt)
      return @listener.mouse_moved(evt)
    end
    
    def mousePressed(mouse_event, mouse_button_ID)
      return @listener.mouse_pressed(mouse_event, mouse_button_ID)
    end

    def mouseReleased(mouse_event, mouse_button_ID)
      return @listener.mouse_released(mouse_event, mouse_button_ID)
    end
  end

  #
  # Tray Listener
  #
  class TrayListener < OgreBites::SdkTrayListener
    def initialize(listener)
      super()
      @listener = listener
    end

    def buttonHit(button)
      @listener.button_Hit(button)
    end
    
    def itemSelected(menu)
      @listener.item_Selected(menu)
    end
    
    def yesNoDialogClosed(name, bl)
      @listener.yes_no_dialog_closed(name, bl)
    end
    
    def okDialogClosed(name)
      @listener.ok_dialog_closed(name)
    end
  end

end # module 

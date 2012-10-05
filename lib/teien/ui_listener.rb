module Teien
  #
  # Key Listener
  #
  class KeyListener < Ois::KeyListener
    def initialize(listener)
      super()
      @listener = listener
    end

    def key_pressed(key_event)
      return @listener.key_pressed(key_event)
    end
    
    def key_released(key_event)
      return @listener.key_released(key_event)
    end
  end

  #
  # Mouse Listener
  #
  class MouseListener < Ois::MouseListener
    def initialize(listener)
      super()
      @listener = listener
    end

    def mouse_moved(evt)
      return @listener.mouse_moved(evt)
    end
    
    def mouse_pressed(mouse_event, mouse_button_ID)
      return @listener.mouse_pressed(mouse_event, mouse_button_ID)
    end

    def mouse_released(mouse_event, mouse_button_ID)
      return @listener.mouse_released(mouse_event, mouse_button_ID)
    end
  end

  #
  # Tray Listener
  #
  class TrayListener < Ogrebites::SdkTrayListener
    def initialize(listener)
      super()
      @listener = listener
    end

    def button_hit(button)
      @listener.button_hit(button)
    end
    
    def item_selected(menu)
      @listener.item_selected(menu)
    end
    
    def yes_no_dialog_closed(name, bl)
      @listener.yes_no_dialog_closed(name, bl)
    end
    
    def ok_dialog_closed(name)
      @listener.ok_dialog_closed(name)
    end
  end

end # module 

require 'teien'

module Teien

class Controller
  @@controllers = Array.new
  @@loaded_controllers = Array.new

  @garden = nil
  @ui = nil

  def initialize(garden, ui)
    @garden = garden
    @garden.register_receiver(self)
    @ui = ui
    @ui.register_receiver(self)
  end

  def self.inherited(klass)
    @@controllers.push(klass)
  end

  def self.load(garden, ui)
    @@controllers.each {|ctl|
      @@loaded_controllers.push(ctl.new(garden, ui))
    }
  end
end

end

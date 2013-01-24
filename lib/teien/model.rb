require 'teien'

module Teien

class Model
  @@models = Array.new
  @@loaded_models = Array.new

  def initialize(event_router, garden)
    @event_router = event_router
    @event_router.register_receiver(self)
    @garden = garden
    @garden.register_receiver(self)

=begin
    # set config files.
    fileDir = File.dirname(File.expand_path(__FILE__))
    @garden.plugins_cfg = "#{fileDir}/plugins.cfg"
    @garden.resources_cfg = "#{fileDir}/resources.cfg"
=end
  end

  def self.inherited(klass)
    @@models.push(klass)
  end

  def self.load(event_router, garden)
    @@models.each {|ctl|
      @@loaded_models.push(ctl.new(event_router, garden))
    }
  end

  def self.loaded_models
    return @@loaded_models
  end
end

end

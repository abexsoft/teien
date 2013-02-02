require 'teien'

module Teien

class Model
  @@models = Array.new
  @@loaded_models = Array.new

  def initialize(event_router, base_object_manager)
    @event_router = event_router
    @event_router.register_receiver(self)
    @base_object_manager = base_object_manager
    @base_object_manager.register_receiver(self)

=begin
    # set config files.
    fileDir = File.dirname(File.expand_path(__FILE__))
    @base_object_manager.plugins_cfg = "#{fileDir}/plugins.cfg"
    @base_object_manager.resources_cfg = "#{fileDir}/resources.cfg"
=end
  end

  def self.inherited(klass)
    @@models.push(klass)
  end

  def self.load(event_router, base_object_manager)
    @@models.each {|ctl|
      @@loaded_models.push(ctl.new(event_router, base_object_manager))
    }
  end

  def self.loaded_models
    return @@loaded_models
  end
end

end

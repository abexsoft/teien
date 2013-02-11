require 'teien'

module Teien

class Application
  @@apps = Array.new
  @@loaded_apps = Array.new

  def initialize()
    @event_router = Teien::get_component("event_router")
    @event_router.register_receiver(self)
    @base_object_manager = Teien::get_component("base_object_manager")
    @base_object_manager.register_receiver(self)

=begin
    # set config files.
    fileDir = File.dirname(File.expand_path(__FILE__))
    @base_object_manager.plugins_cfg = "#{fileDir}/plugins.cfg"
    @base_object_manager.resources_cfg = "#{fileDir}/resources.cfg"
=end
  end

  def self.inherited(klass)
    @@apps.push(klass)
  end

  def self.load(command)
    require "teien/application/application"
    Dir.glob("#{Dir.getwd}/app/#{command}/*.rb") {|file| require "#{file}" }
  end

  def self.instantiate()
    @@apps.each {|app|
      @@loaded_apps.push(app.new())
    }
  end

  def self.loaded_apps
    return @@loaded_apps
  end
end

end

require 'teien'

module Teien

class Model
  @@models = Array.new
  @@loaded_models = Array.new

  @garden = nil

  def initialize(garden)
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

  def self.load(garden)
    @@models.each {|ctl|
      @@loaded_models.push(ctl.new(garden))
    }
  end
end

end

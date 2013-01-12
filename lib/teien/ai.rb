require 'teien'

module Teien

class Ai
  @@ais = Array.new
  @@loaded_ais = Array.new

  @garden = nil

  def initialize(garden)
    @garden = garden
    @garden.register_receiver(self)
  end

  def self.inherited(klass)
    @@ais.push(klass)
  end

  def self.load(garden)
    @@ais.each {|ctl|
      @@loaded_ais.push(ctl.new(garden))
    }
  end
end

end

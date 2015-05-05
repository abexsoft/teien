require_relative '../actor'

module Teien
  class GhostActor <  Teien::Actor
    attr_accessor :mass
    
    def initialize(name, ext_info = nil)
      super(name)
      @type = "Ghost"
    end
    
    def setup(physics)
    end
    
    def to_hash
      hash = super
      hash[:type] = @type
      hash
    end
    
    def from_hash(hash)
      super(hash)
    end
  end
end

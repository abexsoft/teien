module Teien

class Animation
  attr_accessor :enable
  attr_accessor :blend_mode
  attr_accessor :operators

  class Operator
    attr_accessor :name
    attr_accessor :speed
    attr_accessor :loop

    def initialize(name, speed, loop)
      @name = name
      @speed = speed
      @loop = loop
    end
  end

  def initialize()
    @enable = false
    @blend_mode = Ogre::ANIMBLEND_CUMULATIVE
    @operators = Hash.new
  end

  def create_operator(operator_name, animation_name, speed, loop)
    unless @operators[operator_name] 
      @operators[operator_name] = Operator.new(animation_name, speed, loop)
    end
    return @operators[operator_name]
  end
end

end

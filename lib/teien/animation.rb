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
    @operators = Array.new
  end

  def create_operator(name, speed, loop)
    operator = Operator.new(name, speed, loop)
    @operators.push(operator)
    return operator
  end
end

end

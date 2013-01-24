module Teien

class PhysicsInfo
  attr_accessor :mass
  attr_accessor :angular_factor # rotate along Y axis if 1.0
  attr_accessor :friction      
  attr_accessor :restitution   
  attr_accessor :linear_damping
  attr_accessor :angular_damping
  attr_accessor :collision_filter

  def initialize(mass = 1.0)
    @mass = mass
    @angular_factor = 1.0
    @restitution = 0.2
    @friction = 1.0
    @linear_damping = 0.0
    @angular_damping = 0.0
    @collision_filter = nil
  end
end


end

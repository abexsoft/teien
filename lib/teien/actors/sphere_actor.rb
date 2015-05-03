require_relative '../actor'

module Teien
  class SphereActor <  Teien::Actor
    attr_accessor :mass
    attr_accessor :col_obj
    attr_accessor :inertia
    attr_accessor :rigid_body
    
    def initialize(name, radius = 1, mass = 1)
      super(name)
      @type = "Sphere"
      @radius = radius
      @mass = mass
    end
    
    def setup(physics)
      # create a physics object.
      @col_obj = Bullet::BtSphereShape.new(@radius)
      @inertia = Bullet::BtVector3.new()
      @col_obj.calculate_local_inertia(@mass, @inertia)
      @rigid_body = Bullet::BtRigidBody.new(@mass, self, @col_obj, inertia)
      physics.add_rigid_body(@rigid_body)
    end
    
    def to_hash
      hash = super
      hash[:type] = @type
      hash[:radius] = @radius
      hash[:mass] = @mass
      hash
    end
    
    def from_hash(hash)
      super(hash)
      @radius = hash[:radius]
      @mass = hash[:mass]
    end
  end
end

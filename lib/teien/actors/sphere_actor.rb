require_relative '../actor'

module Teien
  class SphereActor <  Teien::Actor
    attr_accessor :mass
    attr_accessor :col_obj
    attr_accessor :inertia
    attr_accessor :rigid_body
    
    def initialize(name, radius = 1, physics_info = nil, ext_info = nil)
      super(name, physics_info, ext_info)
      @type = "Sphere"
      @radius = radius
    end
    
    def setup(physics)
      # create a physics object.
      @col_obj = Bullet::BtSphereShape.new(@radius)
      @inertia = Bullet::BtVector3.new()
      @col_obj.calculate_local_inertia(@physics_info[:mass], @inertia)
      @rigid_body = Bullet::BtRigidBody.new(@physics_info[:mass], self, @col_obj, inertia)
      super(physics)
      physics.add_rigid_body(@rigid_body)
    end
    
    def to_hash
      hash = super
      hash[:type] = @type
      hash[:radius] = @radius
      hash
    end
    
    def from_hash(hash)
      super(hash)
      @radius = hash[:radius]
    end
  end
end

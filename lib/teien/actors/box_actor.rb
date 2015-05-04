module Teien
  class BoxActor < Teien::Actor
    
    def initialize(name, vec = Teien::Vector3D.new(1, 1, 1), physics_info = nil, ext_info = nil)
      super(name, physics_info, ext_info)              
      @type = 'Box'
      @vec = vec
    end     
            
    def setup(physics)
      # create a physics object.
      @col_obj = Bullet::BtBoxShape.new(Bullet::BtVector3.new(@vec.x / 2.0, @vec.y / 2.0, @vec.z / 2.0))
      inertia = Bullet::BtVector3.new
      @col_obj.calculate_local_inertia(@physics_info[:mass], inertia)
      
      @rigid_body = Bullet::BtRigidBody.new(@physics_info[:mass], self, @col_obj, inertia)
      super(physics)      
      physics.add_rigid_body(@rigid_body)      
    end

    def set_angular_factor(vec)
      @rigid_body.set_angular_factor(Bullet::BtVector3.new(vec.x, vec.y, vec.z)) 
    end 
    
    def to_hash
      hash = super
      hash[:type] = @type      
      hash[:x] = @vec.x
      hash[:y] = @vec.y
      hash[:z] = @vec.z      
      hash
    end
    
    def from_hash(hash)
      super
      @vec.x = hash[:x]
      @vec.y = hash[:y]
      @vec.z = hash[:z]
    end
  end
end

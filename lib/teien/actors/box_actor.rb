module Teien
  class BoxActor < Teien::Actor
    def initialize(name, vec = Teien::Vector3D.new(1, 1, 1), mass = 1)
      super(name)              
      @type = 'Box'
      @vec = vec
      @mass = mass  
    end     
            
    def setup(physics)
      # create a physics object.
      @col_obj = Bullet::BtBoxShape.new(Bullet::BtVector3.new(@vec.x / 2.0, @vec.y / 2.0, @vec.z / 2.0))
      inertia = Bullet::BtVector3.new
      @col_obj.calculate_local_inertia(@mass, inertia)
      
      @rigid_body = Bullet::BtRigidBody.new(@mass, self, @col_obj, inertia)
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
      hash[:mass] = @mass
      hash
    end
    
    def from_hash(hash)
      super
      @vec.x = hash[:x]
      @vec.y = hash[:y]
      @vec.z = hash[:z]
      @mass  = hash[:mass]
    end
  end
end

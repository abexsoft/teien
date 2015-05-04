require_relative './physics'

module Teien
  class Actor < Bullet::BtMotionState
    attr_accessor :name
    attr_accessor :state

    attr_accessor :physics_info
    attr_accessor :ext_info
    
    def initialize(name, physics_info = nil, ext_info = nil)
      super() # This is ultimate important for detecting overloaded method.
      
      @name = name
      @state = "none"
      @physics_info = check_physics_info(physics_info)
      @ext_info = ext_info ? ext_info : {}

      @transform = Bullet::BtTransform.new()
      @transform.set_identity()

      @rigid_body = nil
    end

    def check_physics_info(physics_info)
      @physics_info = {}
      @physics_info[:use_physics] = physics_info == nil ? false : true
      return @physics_info if (physics_info == nil)
      
      @physics_info[:mass] = physics_info[:mass] == nil ? 0 : physics_info[:mass]
      @physics_info[:restitution] = physics_info[:restitution] == nil ? 0.2 : physics_info[:restitution]
      @physics_info[:friction] = physics_info[:friction] == nil ? 1.0 : physics_info[:friction]
      @physics_info[:linear_damping] = physics_info[:linear_damping] == nil ? 0.0 : physics_info[:linear_damping]
      @physics_info[:angular_damping] = physics_info[:angular_damping] == nil ? 0.0 : physics_info[:angular_damping]
      
      @physics_info
    end

    def setup(physics)
      if(@rigid_body)
        @rigid_body.set_restitution(@physics_info[:restitution])
        @rigid_body.set_friction(@physics_info[:friction])
        @rigid_body.set_damping(@physics_info[:linear_damping],
                                @physics_info[:angular_damping])
=begin         
        rigid_body.setAngularFactor(new Ammo.btVector3(actorInfo.angularFactor.x,
                                                      actorInfo.angularFactor.y,
                                                      actorInfo.angularFactor.z));
=end
      end
    end
    
    def set_world_transform(worldTrans)
      @transform = Bullet::BtTransform.new(worldTrans)
#      rot = @transform.get_rotation();
#      puts "set_world_transform::rot(#{rot.x}, #{rot.y}, #{rot.z}, #{rot.w})"
    end

    def get_world_transform(worldTrans)
#      @transform = @rigid_body.get_center_of_mass_transform() if (@rigid_body)
      worldTrans.set_origin(@transform.get_origin())
      worldTrans.set_rotation(@transform.get_rotation())
    end
    
    def set_position(vec)
      @transform.set_origin(Bullet::BtVector3.new(vec.x, vec.y, vec.z))
      @rigid_body.set_center_of_mass_transform(@transform) if @rigid_body
    end

    def set_rotation(quat)
      @transform.set_rotation(Bullet::BtQuaternion.new(quat.x, quat.y, quat.z, quat.w))
      @rigid_body.set_center_of_mass_transform(@transform) if @rigid_body
    end

    def set_linear_velocity(vec)
      @rigid_body.set_linearr_velocity(vec) if @rigid_body
    end

    def get_linear_velocity()
      return @rigid_body.get_linear_velocity() if @rigid_body
      return Bullet::BtVector3.new
    end    

    def get_angular_velocity()
      return @rigid_body.get_angular_velocity() if @rigid_body
      return Bullet::BtVector3.new
    end    

    def to_hash
      pos = @transform.get_origin()
      rot = @transform.get_rotation()
      linear_vel = get_linear_velocity()
      angular_vel = get_angular_velocity() 
      
      { 
        :name => @name,
        :state => @state,
        :physics_info => @physics_info,
        :transform => {
          :position => {
            :x => pos.x,
            :y => pos.y,
            :z => pos.z
          },
          :rotation => {
            :x => rot.x,
            :y => rot.y,
            :z => rot.z,
            :w => rot.w
          }
        },
        :linear_vel => {
          :x => linear_vel.x,
          :y => linear_vel.y,
          :z => linear_vel.z          
        },
        :angular_vel => {
          :x => angular_vel.x,
          :y => angular_vel.y,
          :z => angular_vel.z          
        },
        :ext_info => @ext_info
      }
    end

    def from_hash(hash)
      @name = hash[:name]
      @state = hash[:state]
      @transform.from_hash(hash[:transform])
      @ext_info = hash[:ext_info]
    end

    def update(delta)
    end
  end
end

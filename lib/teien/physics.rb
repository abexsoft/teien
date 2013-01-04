require "teien/physics_object_factory.rb"

module Teien

CollisionFilter = Struct.new(:group, :mask)

class ContactResult < Bullet::ContactResultCallback
  def initialize
    super

    @isCollided = false
  end

  def collided?
    return @isCollided
  end

  def add_single_result(cp, 
                        colObj0, partId0, index0,
                        colObj1, partId1, index1)
    @isCollided = true
    return 0
  end
end


class Physics < Bullet::TickListener
  attr_accessor :dynamics_world
  attr_accessor :max_sub_steps
  attr_accessor :fixed_time_step
#  attr_accessor :softBodyWorldInfo

  def initialize()
    super()

    @object_factory = PhysicsObjectFactory.new(self)
    @rigid_bodies = []

    @max_sub_steps = 1
    @fixed_time_step = 1.0 / 60.0
  end

  def set_gravity(vec)
    @dynamics_world.set_gravity(vec)
  end

  def setup(garden)
    @garden = garden
    @collision_config = Bullet::BtDefaultCollisionConfiguration.new()
    @collision_dispatcher = Bullet::BtCollisionDispatcher.new(@collision_config)

    worldAabbMin = Bullet::BtVector3.new(-3000.0,-500.0, -3000.0)
    worldAabbMax = Bullet::BtVector3.new(3000.0, 500.0, 3000.0)
    maxProxies = 1024 * 4
    @aabb_cache = Bullet::BtAxisSweep3.new( worldAabbMin, worldAabbMax, maxProxies )

    @solver = Bullet::BtSequentialImpulseConstraintSolver.new();

    @dynamics_world = Bullet::BtDiscreteDynamicsWorld.new(@collision_dispatcher, @aabb_cache,
                                                          @solver, @collision_config)
    gravity = Bullet::BtVector3.new(0.0, -9.8, 0.0)
    @dynamics_world.set_gravity(gravity)

    @dynamics_world.set_internal_tick_callback(self, true);     
    @dynamics_world.set_internal_tick_callback(self, false);     
=begin
    worldAabbCache->getOverlappingPairCache()->setInternalGhostPairCallback(new btGhostPairCallback());
=end    
=begin
    @softBodyWorldInfo = Bullet::BtSoftBodyWorldInfo.new
    softBodyWorldInfo.m_dispatcher = @collisionDispatcher
    softBodyWorldInfo.m_broadphase = @gardenAabbCache
    softBodyWorldInfo.m_gravity.setValue(0, -9.8, 0)
#    softBodyWorldInfo.m_sparsesdf.Initialize();
=end
  end

  def finalize
    # clear all objects.
    @rigid_bodies.each{|body|
      @dynamics_world.remove_rigid_body(body)
    }
    @rigid_bodies = []

#    @dynamics_world.finalize()
  end

  def add_physics_object(obj)
    obj.physics_object = @object_factory.create_object(obj)

    if (obj.physics_object.rigid_body != nil && 
        obj.object_info.class != LightObjectInfo)
      
      if (obj.physics_info.collision_filter)
        add_rigid_body(obj.physics_object.rigid_body, 
                       obj.physics_info.collision_filter) 
      else
        add_rigid_body(obj.physics_object.rigid_body) 
      end
    end
  end

  def add_rigid_body(rigid_body, collision_filter = nil)
    @rigid_bodies.push(rigid_body)
    if (collision_filter)
      @dynamics_world.add_rigid_body(rigid_body, collision_filter.group, collision_filter.mask)
    else
      @dynamics_world.add_rigid_body(rigid_body)
    end
  end

  def del_rigid_body(rigid_body)
    @rigid_bodies.delete(rigid_body)
    @dynamics_world.remove_rigid_body(rigid_body)
  end

  def update(delta)
    @dynamics_world.step_simulation(delta, @max_sub_steps, @fixed_time_step)
    return true
  end

  def frame_rendering_queued(evt)
#    print "Physics::tick: ", evt.timeSinceLastFrame * 1000, "ms\n"
    @dynamics_world.step_simulation(evt.timeSinceLastFrame, @max_sub_steps, @fixed_time_step)
    return true
  end

  def flush_pair_cache(rigid_body)
    pair_cache = @dynamics_world.get_broadphase().get_overlapping_pair_cache()
    pair_cache.remove_overlapping_pairs_containing_proxy(rigid_body.get_broadphase_handle(), 
                                                         @dynamics_world.get_dispatcher())
  end

  def contact_pair_test(colObjA, colObjB)
    result = ContactResult.new
    @dynamics_world.contact_pair_test(colObjA, colObjB, result)
    return result
  end

  def pre_tick_callback(timeStep)
#    print "pre_tick_callback: ", timeStep * 1000, "ms\n"
    delta = Bullet::BtVector3.new(timeStep, timeStep, timeStep)

    @garden.objects.each {|name, obj|
      if (obj.get_mass() > 0)
        newVel = obj.get_linear_velocity() + obj.get_acceleration() * delta
        obj.set_linear_velocity(obj.limit_velocity(newVel))
        lastVel = obj.get_linear_velocity()
      end
    }
  end

  def tick_callback(timeStep)
#    print "tick_callback: ", timeStep * 1000, "ms\n"
  end
end

end

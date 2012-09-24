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

  def addSingleResult(cp, 
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

  def initialize(garden)
    super()
    @garden = garden

    @max_sub_steps = 1
    @fixed_time_step = 1.0 / 60.0

    @rigid_bodies = []
  end

  def setup
    @collision_config = Bullet::BtDefaultCollisionConfiguration.new();
    @collision_dispatcher = Bullet::BtCollisionDispatcher.new(@collision_config)

    worldAabbMin = Bullet::BtVector3.new(-3000.0,-500.0, -3000.0)
    worldAabbMax = Bullet::BtVector3.new(3000.0, 500.0, 3000.0)
    maxProxies = 1024 * 4
    @aabb_cache = Bullet::BtAxisSweep3.new( worldAabbMin, worldAabbMax, maxProxies )

    @solver = Bullet::BtSequentialImpulseConstraintSolver.new();

    @dynamics_world = Bullet::BtDiscreteDynamicsWorld.new(@collision_dispatcher, @aabb_cache,
                                                          @solver, @collision_config)
    gravity = Bullet::BtVector3.new(0.0, -9.8, 0.0)
    @dynamics_world.setGravity(gravity)

    @dynamics_world.setInternalTickCallback(self, true);     
    @dynamics_world.setInternalTickCallback(self, false);     
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
      @dynamics_world.removeRigidBody(body)
    }
    @rigid_bodies = []

#    @dynamics_world.finalize()
  end

  def update(delta)
    @dynamics_world.stepSimulation(delta, @max_sub_steps, @fixed_time_step)
    return true
  end

  def frameRenderingQueued(evt)
#    print "Physics::tick: ", evt.timeSinceLastFrame * 1000, "ms\n"
    @dynamics_world.stepSimulation(evt.timeSinceLastFrame, @max_sub_steps, @fixed_time_step)
    return true
  end

  def flush_pair_cache(rigid_body)
    pair_cache = @dynamics_world.getBroadphase().getOverlappingPairCache()
    pair_cache.removeOverlappingPairsContainingProxy(rigid_body.getBroadphaseHandle(), 
                                                     @dynamics_world.getDispatcher())
  end

  def set_gravity(vec)
    @dynamics_world.setGravity(vec)
  end

=begin
  def create_box_shape(size)
    return Bullet::BtBoxShape.new(size)
  end

  def createSphereShape(radius)
    return Bullet::BtSphereShape.new(radius)
  end
=end

  def create_rigid_body(mass, motionState, colObj, inertia)
    rigid_body = Bullet::BtRigidBody.new(mass, motionState, colObj, inertia)
    rigid_body.instance_variable_set(:@collision_shape, colObj) # prevent this colObj from GC.
    return rigid_body
  end

  def add_rigid_body(rigid_body, collision_filter = nil)
    @rigid_bodies.push(rigid_body)
    if (collision_filter)
      @dynamics_world.addRigidBody(rigid_body, collision_filter.group, collision_filter.mask)
    else
      @dynamics_world.addRigidBody(rigid_body)
    end
  end

  def contact_pair_test(colObjA, colObjB)
    result = ContactResult.new
    @dynamics_world.contactPairTest(colObjA, colObjB, result)
    return result
  end

  def preTickCallback(timeStep)
#    print "preTickCallback: ", timeStep * 1000, "ms\n"
    delta = Bullet::BtVector3.new(timeStep, timeStep, timeStep)

    @garden.objects.each {|name, obj|
      if (obj.get_mass() > 0)
        newVel = obj.get_linear_velocity() + obj.get_acceleration() * delta
        obj.set_linear_velocity(obj.limit_velocity(newVel))
        lastVel = obj.get_linear_velocity()
      end
    }
  end

  def tickCallback(timeStep)
#    print "tickCallback: ", timeStep * 1000, "ms\n"
  end
end

end

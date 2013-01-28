require_relative "sinbad_state"

class ClosestNotMe < Bullet::ClosestRayResultCallback
  def initialize(rb)
    super(Bullet::BtVector3.new(0.0, 0.0, 0.0), Bullet::BtVector3.new(0.0, 0.0, 0.0))
    @rigidBody = rb
  end

  def addSingleResult(rayResult, normalInWorldSpace)
    return 1.0 if (rayResult.m_collisionObject == @rigedBody)
    return super(rayResult, normalInWorldSpace)
  end
end

class Sinbad
  attr_accessor :garden
  attr_accessor :name

  attr_accessor :object
  attr_accessor :mover
  attr_accessor :sm_mover
  attr_accessor :grav_mover
  attr_accessor :state

  def initialize(garden, name)
    @garden = garden

    @name = name
    build_object()

    # moves this charactor smoothly.
    @sm_mover = SmoothMover.new(@object)
    @sm_mover.acceleration = 50

    @object.animation_info.create_operator("TopAnim", "IdeleTop", 1.0, true)
    @object.animation_info.create_operator("BaseAnim", "IdleBase", 1.0, true)
    @object.animation_info.create_operator("HandsAnim", "HandsRelaxed", 1.0, true)

    @mover = @sm_mover
    @state = SinbadState.new(self)
  end

  def finalize()
    @garden.objects.delete(@object.name)
    @object.finalize()
  end

  def dump_event()
    return Event::SyncSinbad.new(self)
  end

  def self.load_event(garden, actors, event)
    actor = actors[event.actor_name]
    if actor == nil
      actor = Sinbad.new(garden, event.actor_name)
    else
      actor = actors[event.actor_name]
    end

    return actor
  end

  def build_object()
    # sinbad
    object_info = MeshBBObjectInfo.new("sinbad.mesh", Vector3D.new(1.0, 1.0, 1.0))
    object_info.scale = Vector3D.new(1.0 / 2.0, 1.0 / 2.0, 1.0 / 2.0)
    object_info.physics_offset = Vector3D.new(0, 1.0, 0)
    object_info.view_offset = Vector3D.new(0, 2.5, 0)
    object_info.view_rotation = Quaternion.new(Vector3D.new(0, 1, 0), Ogre::Degree.new(180.0).value_radians)
    physics_info = PhysicsInfo.new(1.0)
    physics_info.angular_factor = 0
    physics_info.restitution = 0.5
    physics_info.friction = 0.5
    physics_info.linear_damping = 0.5
    physics_info.angular_damping = 0
    @object = @garden.create_object(@name, object_info, physics_info)
    @object.set_position(Vector3D.new(0, 0, 0))

=begin
    # swords
    object_info = MeshObjectInfo.new("Sword.mesh")
    object_info.scale = Vector3D.new(1.0 / 2.0, 1.0 / 2.0, 1.0 / 2.0)
    @sword1 = @garden.create_object("SinbadSword1", object_info, PhysicsInfo.new(1.0))
    @object.attach_object_to_bone("Sheath.L", @sword1)

    object_info = MeshObjectInfo.new("Sword.mesh")
    object_info.scale = Vector3D.new(1.0 / 2.0, 1.0 / 2.0, 1.0 / 2.0)
    @sword2 = @garden.create_object("SinbadSword2", object_info, PhysicsInfo.new(1.0))
    #@object.entity.attach_object_to_bone("Sheath.R", @sword2)
=end
  end

  def update(delta)
    @state.update(delta)
  end

  def check_on_ground()
    rayCallback = ClosestNotMe.new(@object.physics_object.rigid_body)
    rayCallback.m_closestHitFraction = 1.0
    src = @object.get_position() + Vector3D.new(0, 0.1, 0)
    tgt = src + Vector3D.new(0, -0.2, 0)

#    puts "src(#{src.x}, #{src.y}, #{src.z})"
#    puts "tgt(#{tgt.x}, #{tgt.y}, #{tgt.z})"

    @garden.physics.dynamics_world.ray_test(src, tgt, rayCallback)
    return true if (rayCallback.has_hit())
    return false
  end

  def set_forward_direction(dir)
    @mover.set_forward_direction(dir)
  end

  def move_forward(bl)
    @mover.move_forward(bl)
  end

  def move_backward(bl)
    @mover.move_backward(bl)
  end

  def move_left(bl)
    @mover.move_left(bl)
  end

  def move_right(bl)
    @mover.move_right(bl)
  end

  def jump(bl)
    if bl
      if @state.state?("GravityFree")
      elsif @state.state?("JumpLoop")
      else
        @state.set_state("Jump")
      end
    end
  end

  def action_left()
    @object.detach_object_from_bone(@sword1)
    #@state.set_state("Kick")
  end

  def action_right
    @state.set_state("Attack")
  end

  def press_gravity
    @state.set_state("GravityFree")
  end

  def release_gravity
  end

  def stop_gravity
    @object.set_gravity(Vector3D.new(0, -9.8, 0))
    @state.set_state("InAir")
  end

  def play_top_animation(name, loop = true)
    @object.animation_info.operators["TopAnim"].name = name
    @object.animation_info.operators["TopAnim"].loop = loop
  end

  def play_base_animation(name, loop = true)
    @object.animation_info.operators["BaseAnim"].name = name
    @object.animation_info.operators["BaseAnim"].loop = loop
  end

  def play_hands_animation(name, loop = true)
    @object.animation_info.operators["HandsAnim"].name = name
    @object.animation_info.operators["HnadsAnim"].loop = loop
  end
end

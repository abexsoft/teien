require_relative "sinbad/sinbad_state"
require_relative "sinbad/sinbad_info"

class ClosestNotMe < Bullet::ClosestRayResultCallback
  def initialize(rb)
    super(Bullet::BtVector3.new(0.0, 0.0, 0.0), Bullet::BtVector3.new(0.0, 0.0, 0.0))
    @rigidBody = rb
  end

  def add_single_result(rayResult, normalInWorldSpace)
    return 1.0 if (rayResult.m_collisionObject == @rigedBody)
    return super(rayResult, normalInWorldSpace)
  end
end


include Teien

require "teien/action_model/smooth_moving"

class Sinbad < Teien::Actor
  attr_accessor :object
  attr_accessor :actor
  attr_accessor :mover
  attr_accessor :state

  def initialize(sinbad_info)
    @base_object_manager = Teien::get_component("base_object_manager")

    build_object(sinbad_info)

    @mover = SmoothMoving.new(@object.name)
    @mover.acceleration = 50

    @state = SinbadState.new(self)
  end

  def finalize()
    @base_object_manager.objects.delete(@object.name)
    @base_object_manager.objects.delete("SinbadSword1")
    @base_object_manager.objects.delete("SinbadSword2")
    @object.finalize()
  end


  def dump_event()
    return Event::SyncSinbad.new(self)
  end


  def self.load_event(base_object_manager, actors, event)
    actor = actors[event.actor_name]
    if actor == nil
      actor = Sinbad.new(base_object_manager, event.actor_name)
    else
      actor = actors[event.actor_name]
    end

    return actor
  end

  def build_object(sinbad_info)
    @name = sinbad_info.actor_name

    if sinbad_info.object_name
      @object = @base_object_manager.objects[sinbad_info.object_name]
      @animation = Teien::get_component("animation_manager").animations[@object.name]
    else
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
      @object = @base_object_manager.create_object(@name, object_info, physics_info)
      @object.set_position(Vector3D.new(0, 0, 0))

      event = Teien::Event::BaseObject::SyncObject.new(@object)
      Teien::get_component("event_router").send_event(event)
      
      @animation = Teien::get_component("animation_manager").create_animation(@object.name)
      @animation.create_operator("TopAnim", "IdeleTop", 1.0, true)
      @animation.create_operator("BaseAnim", "IdleBase", 1.0, true)
      @animation.create_operator("HandsAnim", "HandsRelaxed", 1.0, true)

      event = Teien::Event::Animation::SyncAnimation.new(@object.name, @animation)
      Teien::get_component("event_router").send_event(event)
    end


    # swords
    object_info = MeshObjectInfo.new("Sword.mesh")
    object_info.scale = Vector3D.new(1.0 / 2.0, 1.0 / 2.0, 1.0 / 2.0)
    @sword1 = @base_object_manager.create_object("SinbadSword1", object_info)
    @object.attach_object_to_bone("Sheath.L", @sword1)

    object_info = MeshObjectInfo.new("Sword.mesh")
    object_info.scale = Vector3D.new(1.0 / 2.0, 1.0 / 2.0, 1.0 / 2.0)
    @sword2 = @base_object_manager.create_object("SinbadSword2", object_info)
    @object.attach_object_to_bone("Sheath.R", @sword2)
  end

  def receive_event(event, from)
  end

  def update(delta)
      @state.update(delta) if @state
  end

  def check_on_ground()
    rayCallback = ClosestNotMe.new(@object.physics_object.rigid_body)
    rayCallback.m_closestHitFraction = 1.0
    src = @object.get_position() + Vector3D.new(0, 0.1, 0)
    tgt = src + Vector3D.new(0, -0.2, 0)

#    puts "src(#{src.x}, #{src.y}, #{src.z})"
#    puts "tgt(#{tgt.x}, #{tgt.y}, #{tgt.z})"

    @base_object_manager.physics.dynamics_world.ray_test(src, tgt, rayCallback)
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
      unless @state.state?("JumpLoop")
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

  def play_top_animation(name, loop = true)
    @animation.operators["TopAnim"].name = name
    @animation.operators["TopAnim"].loop = loop
  end

  def play_base_animation(name, loop = true)
    @animation.operators["BaseAnim"].name = name
    @animation.operators["BaseAnim"].loop = loop
  end

  def play_hands_animation(name, loop = true)
    @animation.operators["HandsAnim"].name = name
    @animation.operators["HnadsAnim"].loop = loop
  end
end

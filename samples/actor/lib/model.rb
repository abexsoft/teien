require_relative "event"
require_relative "sinbad"

module Model
  def model_setup()
    @remote_to_controllables = Hash.new

    @sync_period = 0.5
    @sync_timer = 0

    # environment
    @base_object_manager.set_gravity(Vector3D.new(0.0, -9.8, 0.0))
    @base_object_manager.set_ambient_light(Color.new(0.4, 0.4, 0.4))
    @base_object_manager.set_sky_dome(true, "Examples/CloudySky", 5, 8)

    @actor_manager = Teien::get_component("actor_manager")

    # light
    object_info = LightObjectInfo.new(LightObjectInfo::DIRECTIONAL)
    object_info.diffuse_color = Color.new(1.0, 1.0, 1.0)
    object_info.specular_color = Color.new(0.25, 0.25, 0)
    object_info.direction = Vector3D.new( -1, -1, -1 )
    light = @base_object_manager.create_object("light", object_info, PhysicsInfo.new(0))
    light.set_position(Vector3D.new(0, 0, 0))

    # create a floor.
    object_info = FloorObjectInfo.new(50, 50, 0.5, 1, 1, 5, 5)
    object_info.material_name = "Examples/Rockwall"
    floor = @base_object_manager.create_object("Floor", object_info, PhysicsInfo.new(0))
    floor.set_position(Vector3D.new(0, 0, 0))
  end

  def model_connection_binded(from)
  end

  def model_connection_unbinded(from)
    actor = @remote_to_controllables[from]
    if actor
      @remote_to_controllables.delete(from)
      @actor_manager.actors.delete(actor.name)
      actor.finalize()
    end
  end

  ##
  # EventRouter handlers
  #

  def model_receive_event(event, from)
    case event
    when Teien::Event::ReadyToGo
      puts "ReadyToGo"

      remote_info = Network.connections[from]
      
      actor_info = SinbadInfo.new("Sinbad-#{remote_info.id}")
      @sinbad = @actor_manager.create_actor(actor_info)
      @remote_to_controllables[from] = @sinbad

      actor_info.object_name = @sinbad.object.name
      event = Teien::Event::Actor::SyncActor.new(actor_info)
      @event_router.send_event(event)

      event = Teien::Event::ControllableActor.new(@sinbad.name)
      @event_router.send_event(event, from)

    when Teien::Event::Actor::RequestSetForwardDirection
      @remote_to_controllables[from].set_forward_direction(event.dir)
      @event_router.send_event(Teien::Event::Actor::SetForwardDirection.new.copy(event))

    when Teien::Event::Actor::RequestEnableAction
      if event.forward
        @remote_to_controllables[from].move_forward(true)
      elsif event.backward
        @remote_to_controllables[from].move_backward(true)
      elsif event.left
        @remote_to_controllables[from].move_left(true)
      elsif event.right
        @remote_to_controllables[from].move_right(true)
      elsif event.jump
        @remote_to_controllables[from].jump(true)
      end
      @event_router.send_event(Teien::Event::Actor::EnableAction.new(event.actor_name).copy(event))

    when Teien::Event::Actor::RequestDisableAction
      if event.forward
        @remote_to_controllables[from].move_forward(false)
      elsif event.backward
        @remote_to_controllables[from].move_backward(false)
      elsif event.left
        @remote_to_controllables[from].move_left(false)
      elsif event.right
        @remote_to_controllables[from].move_right(false)
      elsif event.jump
        @remote_to_controllables[from].jump(false)
      end
      @event_router.send_event(Teien::Event::Actor::DisableAction.new(event.actor_name).copy(event))
    end
  end
end

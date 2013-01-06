require 'teien'

require_relative './user_event'
require_relative 'sinbad/sinbad'
require_relative 'controller'

include Teien

class ActorModel
  attr_accessor :info
  attr_accessor :quit

  def initialize(garden)
    @garden = garden
    @quit = false
    @garden.register_receiver(self)

    @remote_to_actors = Hash.new
    @sync_period = 0.5
    @sync_timer = 0
=begin
    # set config files.
    fileDir = File.dirname(File.expand_path(__FILE__))
    @garden.plugins_cfg = "#{fileDir}/plugins.cfg"
    @garden.resources_cfg = "#{fileDir}/resources.cfg"
=end
  end

  def setup(garden)
    puts "model::setup"
    # environment
    @garden.set_gravity(Vector3D.new(0.0, -9.8, 0.0))
    @garden.set_ambient_light(Color.new(0.4, 0.4, 0.4))
    @garden.set_sky_dome(true, "Examples/CloudySky", 5, 8)

    # light
    object_info = LightObjectInfo.new(LightObjectInfo::DIRECTIONAL)
    object_info.diffuse_color = Color.new(1.0, 1.0, 1.0)
    object_info.specular_color = Color.new(0.25, 0.25, 0)
    object_info.direction = Vector3D.new( -1, -1, -1 )
    light = @garden.create_object("light", object_info, PhysicsInfo.new(0))
    light.set_position(Vector3D.new(0, 0, 0))

    # create a floor.
    object_info = FloorObjectInfo.new(50, 50, 0.5, 1, 1, 5, 5)
    object_info.material_name = "Examples/Rockwall"
    floor = @garden.create_object("Floor", object_info, PhysicsInfo.new(0))
    floor.set_position(Vector3D.new(0, 0, 0))

  end

  def update(delta)
    @sync_timer += delta
    if (@sync_timer > @sync_period)
      @garden.actors.each_value {|actor|
        event = actor.dump_event()
        @garden.send_event(event)      
      }
      @sync_timer = 0
    end
    return !@quit
  end

  def receive_event(event, from)
#    puts event
    case event
    when Event::ClientUnbinded
      actor = @remote_to_actors[from]
      @remote_to_actors.delete(from)
      @garden.actors.delete(actor.name)
      actor.finalize()
    when Event::RequestControllable
      puts "Event::RequestControllable"

      remote_info = Network.connected_clients[from]
      actor = Sinbad.new(@garden, "Sinbad-#{remote_info.id}")
      @garden.actors[actor.name] = actor
      @remote_to_actors[from] = actor
      event = actor.dump_event()
      @garden.send_event(event)

      @sinbad = actor
      event = Event::ControllableObject.new(@sinbad.name, @sinbad.object.name)
      @garden.send_event(event, from)

    when Event::SetForwardDirection
      return if (from == nil)
      @remote_to_actors[from].set_forward_direction(event.dir)
      @garden.send_event(event)
    when Event::EnableAction
      return if (from == nil)
        
      if event.forward
        @remote_to_actors[from].move_forward(true)
      elsif event.backward
        @remote_to_actors[from].move_backward(true)
      elsif event.left
        @remote_to_actors[from].move_left(true)
      elsif event.right
        @remote_to_actors[from].move_right(true)
      elsif event.jump
        @remote_to_actors[from].jump(true)
      end
      @garden.send_event(event)
    when Event::DisableAction
      return if (from == nil)

      if event.forward
        @remote_to_actors[from].move_forward(false)
      elsif event.backward
        @remote_to_actors[from].move_backward(false)
      elsif event.left
        @remote_to_actors[from].move_left(false)
      elsif event.right
        @remote_to_actors[from].move_right(false)
      elsif event.jump
        @remote_to_actors[from].jump(false)
      end
      @garden.send_event(event)
    end
  end
end


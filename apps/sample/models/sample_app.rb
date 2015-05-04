require_relative '../../../lib/teien'
require_relative '../../../lib/teien/actors/sphere_actor'
require_relative '../../../lib/teien/actors/box_actor'

class SampleApp
  def initialize(world)
    @world = world
  end

  def setup
    Teien::log.debug("log testing")

    # Sphere
    actor = Teien::SphereActor.new("sphere", 1, {:mass => 1})
    actor.ext_info = {
      :threejs => {
        :mesh => {
          :geometry => {:sphere => {:radius => 1}},
          :material => {
            :mesh_basic_material => {
              :map => {
                :texture => {
                  :image => 'teien/addons/threejs_ui/three.js/examples/textures/sprite.png'
                }
              }
            }
          }
        }
      }
    }
    @world.add_actor(actor)
    actor.set_position(Teien::Vector3D.new(0, 20, 0))    

    # Box
    actor = Teien::BoxActor.new("box", Teien::Vector3D.new(2, 2, 2), {:mass => 1})
    actor.ext_info = {
      :threejs => {
        :mesh => {
          :geometry => {:box => {:width => 2, :height => 2, :depth => 2}},
          :material => {
            :mesh_basic_material => {
              :map => {
                :texture => {
                  :image => 'teien/addons/threejs_ui/three.js/examples/textures/brick_diffuse.jpg'
                }
              }
            }
          }
        }
      }
    }
    @world.add_actor(actor)
    actor.set_position(Teien::Vector3D.new(0, 1, 0))

    10.times {|i|
      actor = Teien::SphereActor.new("sphere-#{i}", 1, {:mass => 1})
      actor.ext_info = {
        :threejs => {
          :mesh => {
            :geometry => {:sphere => {:radius => 1}},
            :material => {
              :mesh_basic_material => {
                :map => {
                  :texture => {
                    :image => 'teien/addons/threejs_ui/three.js/examples/textures/planets/earth_atmos_2048.jpg'
                  }
                }
              }
            }
          }
        }
      }
      @world.add_actor(actor)
      actor.set_position(Teien::Vector3D.new(-16 + 3 * i, 40, 0))
    }

    # Floor
    actor = Teien::BoxActor.new("floor", Teien::Vector3D.new(100, 1, 100), {:mass => 0})
    actor.ext_info = {
      :threejs => {
        :mesh => {
          :geometry => {:box => {:width => 100, :height => 1,:depth => 100}},
          :material => {
            :mesh_basic_material => {
              :map => {
                :texture => {
                  :image => 'teien/addons/threejs_ui/three.js/examples/textures/brick_bump.jpg'                  
                }
              }
            }
          }
        }
      }
    }
    @world.add_actor(actor)
    actor.set_position(Teien::Vector3D.new(0, -0.5, 0))
    
=begin
    actor = Teien::SphereActor.new("sphere2", 1, 0)
    actor.set_position(Teien::Vector3D.new(0, 0, 0))
    @world.add_actor(actor)    
=end
=begin
    actor = Teien::Actor.new("actor1")
    view_object = Teien::Module::Renderer::Mesh.new
    actor.set_view_object(view_object)
    actor.set_position(Teien::Vector3D.new(0, 0, 2))
    @world.add_actor(actor)

    actor = Teien::Actor.new("actor2")
    # view_object
    g_params = {
      :type => 'box',
      :height => 1,
      :width => 1,
      :depth => 1
    }
    m_params = {
      :type => 'basic_material',
      :color => 0xffffff,
      :map => {
        :type => 'texture',
        :url => 'teien/module/renderer/three.js/examples/textures/crate.gif'
      }
    }
    view_object = Teien::Module::Renderer::Mesh.new(g_params, m_params)
    actor.set_view_object(view_object)
    # physics_object

    actor.set_position(Teien::Vector3D.new(1, 1, 3))
    actor.set_rotation(Teien::Quaternion.new(0.1, 0.1, 0.1, 0.1))
    @world.add_actor(actor)

    actor = Teien::Actor.new("floor")
    g_params = {
      :type => 'box',
      :height => 50,
      :width => 50,
      :depth => 0.1
    }
    m_params = {
      :type => 'basic_material',
      :color => 0xffffff,
      :map => {
        :type => 'texture',
        :url => 'teien/module/renderer/three.js/examples/textures/brick_diffuse.jpg'
      }
    }
    view_object = Teien::Module::Renderer::Mesh.new(g_params, m_params)
    actor.set_view_object(view_object)
    actor.set_position(Teien::Vector3D.new(0, 0, 0))
    @world.add_actor(actor)
=end
  end

  def connected(ws, event)
  end
  
  def receive_message(ws, event)
  end
  
  def disconnected(ws, event)
  end
  
  def update (delta)
  end
end


require_relative '../../../lib/teien'

class SampleApp
  def initialize(world)
    @world = world
  end

  def setup
    Teien::log.debug("log testing")

    # Ambient Light
    actor = Teien::GhostActor.new("ambient_light")
    actor.ext_info = {
      :threejs => {
        :ambient_light => {
          :hex => 0x404040
        }
      }
    }
    @world.add_actor(actor)
    
=begin
    # Spot Light
    actor = Teien::GhostActor.new("spot_light")
    actor.ext_info = {
      :threejs => {
        :spot_light => {
          :hex => 0xffffff,
          :intensity => 2,
          :distance => 0
        }
      }
    }
    @world.add_actor(actor)
    actor.set_position(Teien::Vector3D.new(100, 100, 100))
=end
    
    # Directional Light
    actor = Teien::GhostActor.new("directional_light")
    actor.ext_info = {
      :threejs => {
        :directional_light => {
          :hex => 0xffffff,
          :intensity => 1.5
        }
      }
    }
    @world.add_actor(actor)
    actor.set_position(Teien::Vector3D.new(1, 1, 1))    
    
    
    # Sphere
    actor = Teien::SphereActor.new("sphere", 3, {:mass => 1})
    actor.ext_info = {
      :threejs => {
        :mesh => {
          :geometry => {:sphere => {:radius => 3, :widthSegments => 32, :heightSegments => 32}},
          :material => {
            :mesh_lambert_material => {
              :map => {
                :texture => {
                  :image => 'teien/addons/threejs_ui/three.js/examples/textures/land_ocean_ice_cloud_2048.jpg'
                }
              }
            }
          }
        }
      }
    }
    @world.add_actor(actor)
    actor.set_position(Teien::Vector3D.new(0, 20, 0))    

    # Json, animation
    actor = Teien::GhostActor.new("json")
    actor.ext_info = {
      :threejs => {
        :json => {
          :url => 'teien/addons/threejs_ui/three.js/examples/models/animated/monster/monster.js',
          :morph_anim_mesh => {
            :duration => 1,
            :scale => {:x => 0.005, :y => 0.005, :z => 0.005},            
          }
        }
      }
    }
    @world.add_actor(actor)

=begin
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


    # Json
    #actor = Teien::BoxActor.new("json", Teien::Vector3D.new(2, 2, 2), {:mass => 0})
    actor = Teien::GhostActor.new("json")
    actor.ext_info = {
      :threejs => {
        :json => {
          #:url => 'teien/addons/threejs_ui/three.js/examples/models/animated/monster/monster.js'
          :url => 'teien/addons/threejs_ui/three.js/examples/models/animated/ogro/ogro-light.js'          
        }
      }
    }
    @world.add_actor(actor)
=end
                                                                       
    10.times {|i|
      actor = Teien::SphereActor.new("sphere-#{i}", 1, {:mass => 1})
      actor.ext_info = {
        :threejs => {
          :mesh => {
            :geometry => {:sphere => {:radius => 1, :widthSegments => 32, :heightSegments => 32}},
            :material => {
              :mesh_lambert_material => {
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
            :mesh_lambert_material => {
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


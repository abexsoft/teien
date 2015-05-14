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
    actor = Teien::SphereActor.new("sphere", 2, {:mass => 1.0})
    actor.ext_info = {
      :threejs => {
        :mesh => {
          :geometry => {:sphere => {:radius => 2, :widthSegments => 32, :heightSegments => 32}},
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
    actor.set_position(Teien::Vector3D.new(1, 20, 0))    

=begin    
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

    #4.times {|y|
    2.times {|y|    
      5.times {|z|
        5.times {|x|
          # Box
          actor = Teien::BoxActor.new("box-#{x}-#{y}-#{z}", Teien::Vector3D.new(2, 2, 2), {:mass => 1.0})
          actor.ext_info = {
            :threejs => {
              :mesh => {
                :geometry => {:box => {:width => 2, :height => 2, :depth => 2}},
                :material => {
                  :mesh_lambert_material => {
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
          actor.set_position(Teien::Vector3D.new(-4 + 2 * x, 2 * y, -4 + 2 * z))
        }
      }
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

    @next_time = 10
    @sphere_num = 0
  end

  def connected(ws, event)
  end
  
  def receive_message(ws, event)
  end
  
  def disconnected(ws, event)
  end
  
  def update (delta)
    @next_time -= delta
    if (@next_time < 0)
      @next_time = 3
      @sphere_num += 1
      actor = Teien::SphereActor.new("sphere-#{@sphere_num}", 1, {:mass => 1})
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
      actor.set_position(Teien::Vector3D.new(0, 40, 0))
    end
  end
end


require "teien/version"

require "bullet.so"
require "ogre.so"
require "procedural.so"
require "ois.so"
require "ogrebites.so"
require "teienlib.so"

require "teien/tools.rb"
require 'teien/object_info'
require 'teien/physics_info'
require 'teien/smooth_mover'
require "teien/garden.rb"
require 'teien/camera_mover'

module Teien

def start_standalone_garden(garden_script_klass, controller_script_klass)
  require_relative 'teien/user_interface'

  garden = Teien::Garden.new()
  ui = Teien::UserInterface.new(garden)
  garden_script = garden_script_klass.new(garden)
  controller_script = controller_script_klass.new(ui)
  garden.run
end

def start_server_garden(ip, port, garden_script_klass)
  require "teien/synchronizer"
  garden = Teien::Garden.new()
  garden_script = garden_script_klass.new(garden)
  sync = Synchronizer.new(garden)
  garden.run(ip, port)
end

def start_client_garden(ip, port, controller_script_klass)
  require "teien/proxy_garden.rb"
  require 'teien/user_interface'

  garden = Teien::ProxyGarden.new()
  ui = Teien::UserInterface.new(garden)
  controller_script = controller_script_klass.new(ui)  
  garden.run(ip, port)
end

=begin
def create_garden(klass)
  return Teien::Garden.new(klass)
end

def create_proxy_garden(klass)
  return Teien::ProxyGarden.new(klass)
end
=end

end

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
require 'teien/animation'
require 'teien/smooth_mover'
require "teien/garden.rb"

module Teien

def start_server_garden(ip, port, garden_script_klass, sync_period = 0.5)
  require "teien/synchronizer"
  garden = Teien::Garden.new()
  garden_script = garden_script_klass.new(garden)
  sync = Synchronizer.new(garden, sync_period)
  garden.run(ip, port)
end

def start_client_garden(ip, port, controller_script_klass)
  require "teien/proxy_garden.rb"
  require 'teien/user_interface'

  garden = Teien::ProxyGarden.new()
  ui = Teien::UserInterface.new(garden)
  controller_script = controller_script_klass.new(garden, ui)  
  garden.run(ip, port)
end

def start_standalone_garden(garden_script_klass, controller_script_klass)
  require_relative 'teien/user_interface'

  pid = Process.fork {
    start_server_garden("0.0.0.0", 11922, garden_script_klass, 0.1)
  }
  start_client_garden("0.0.0.0", 11922, controller_script_klass)

  Process.kill("TERM", pid)
  
=begin
  garden = Teien::Garden.new()
  ui = Teien::UserInterface.new(garden)
  garden_script = garden_script_klass.new(garden)
  controller_script = controller_script_klass.new(garden, ui)
  garden.run
=end
end

end

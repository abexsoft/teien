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
require "teien/model.rb"
require "teien/controller.rb"
require "teien/ai.rb"

module Teien

def self.start_server_garden(ip, port, sync_period = 0.5)
  require "teien/synchronizer"

  cwd = Dir.getwd
  Dir.glob("#{cwd}/app/models/*.rb") {|file|
    require "#{file}"
  }

  garden = Teien::Garden.new()
  Teien::Model::load(garden)
#  garden_script = garden_script_klass.new(garden)
  sync = Synchronizer.new(garden, sync_period)
  garden.run(ip, port)
end

def self.start_client_garden(ip, port)
  require "teien/proxy_garden.rb"
  require 'teien/user_interface'

  cwd = Dir.getwd
  Dir.glob("#{cwd}/app/controllers/*.rb") {|file|
    require "#{file}"
  }

  garden = Teien::ProxyGarden.new()
  ui = Teien::UserInterface.new(garden)
  Teien::Controller::load(garden, ui)
#  controller_script = controller_script_klass.new(garden, ui)  
  garden.run(ip, port)
end

def self.start_ai_garden(ip, port)
  require "teien/proxy_garden.rb"

  cwd = Dir.getwd
  Dir.glob("#{cwd}/app/ais/*.rb") {|file|
    require "#{file}"
  }

  garden = Teien::ProxyGarden.new()
  Teien::Ai::load(garden)
  garden.run(ip, port)
end


def self.start_local_garden()
  require_relative 'teien/user_interface'

  pid = Process.fork {
    start_server_garden("0.0.0.0", 11922, 0.1)
  }
  start_client_garden("0.0.0.0", 11922)

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

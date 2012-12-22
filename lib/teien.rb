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
require 'teien/camera_mover'
require 'teien/smooth_mover'


module Teien


def create_garden(klass)
  require "teien/garden.rb"

  return Teien::Garden.new(klass)
end

def create_proxy_garden(klass)
  require "teien/proxy_garden.rb"
  return Teien::ProxyGarden.new(klass)
end




def create_server_garden(url, klass)
  require "teien/server_garden.rb"
  require "ENet.so"

  return Teien::ServerGarden.new(url, klass)
end

def create_client_garden(uri, klass)
  require "teien/client_garden.rb"
  require "ENet.so"

  return MiniatureGarden::ClientGarden.new(uri, klass)
end

end

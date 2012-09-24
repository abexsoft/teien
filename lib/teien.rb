require "teien/version"

require "Bullet.so"
require "Ogre.so"
require "Procedural.so"
require "OIS.so"
require "OgreBites.so"
require "TeienExt.so"

require "teien/tools.rb"
require 'teien/light_object'
require 'teien/object_info'
require 'teien/physics_info'
require 'teien/camera_mover'

module Teien

def create_garden(klass)
  require "teien/garden.rb"

  return Teien::Garden.new(klass)
end

=begin
def createServerGarden(url, klass)
  require "teien/ServerGarden.rb"
  require "ENet.so"

  return MiniatureGarden::ServerGarden.new(url, klass)
end

def createClientGarden(uri, klass)
  require "teien/ClientGarden.rb"
  require "ENet.so"

  return MiniatureGarden::ClientGarden.new(uri, klass)
end
=end

end

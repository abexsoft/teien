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
require 'teien/event'

module Teien

def create_garden(klass)
  require "teien/garden.rb"

  return Teien::Garden.new(klass)
end

def create_proxy_garden(klass)
  require 'teien/camera_mover'
  require "teien/proxy_garden.rb"
  return Teien::ProxyGarden.new(klass)
end

end

require 'teien'

module Teien

class Addon
  @@addons = Array.new
  @@loaded_addons = Array.new

  def self.inherited(klass)
    @@addons.push(klass)
  end

  def self.load()
    require 'teien/addon/addon'
    Dir.glob("#{Dir.getwd}/addons/**/lib/*.rb") {|file| require "#{file}" }
  end

  def self.instantiate()
   @@addons.each {|addon|
      @@loaded_addons.push(addon.new())
    }
  end
end

end

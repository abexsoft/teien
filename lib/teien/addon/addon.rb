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

=begin
  def self.update(delta)
    @@loaded_addons.each {|addon|
      addon.update(delta)
    }
  end

  def self.receive_event(event, from)
    @@loaded_addons.each {|addon|
      addon.receive_event(event, from)
    }
  end
  Teien::get_component("event_router").register_receiver(self)
=end
end

end

require 'teien/garden_object'

module Teien

class PhysicsObjectFactory
  @creators = Hash.new

  def self.create_object(obj, physics)
    if @creators[obj.object_info.class] != nil
      return @creators[obj.object_info.class].call(obj, physics)
    else
      puts "no such class: #{obj.object_info.class}"
      return nil
    end
  end

  def self.set_creator(info_klass, creator)
    @creators[info_klass] = creator
  end
end


end

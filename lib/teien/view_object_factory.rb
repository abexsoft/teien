require 'teien/garden_object'

module Teien

class ViewObjectFactory
  @creators = Hash.new

  def self.create_object(obj, view)
    if @creators[obj.object_info.class] != nil
      return @creators[obj.object_info.class].call(obj, view)
    else
      return nil
    end
  end

  def self.set_creator(info_klass, creator)
    @creators[info_klass] = creator
  end
end

end

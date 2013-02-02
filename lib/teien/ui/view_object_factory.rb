require 'teien/base_object/base_object'

module Teien

class ViewObjectFactory
  @creators = Hash.new

  def self.create_object(obj, view)
    if @creators[obj.object_info.class] != nil
      return @creators[obj.object_info.class].call(obj, view)
    else
      puts "not a supported object: #{obj.object_info.class}"
      return nil
    end
  end

  def self.set_creator(info_klass, creator)
    @creators[info_klass] = creator
  end
end

end

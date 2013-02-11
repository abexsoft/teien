module Teien

class ActorFactory
  @creators = Hash.new

  def self.register_creator(info_klass, creator)
    @creators[info_klass] = creator
  end

  def self.create_actor(actor_info)
    if @creators[actor_info.class] != nil
      return @creators[actor_info.class].call(actor_info)
    else
      puts "No such creator registered for the class: #{actor_info.class}"
      return nil
    end
  end
end

end

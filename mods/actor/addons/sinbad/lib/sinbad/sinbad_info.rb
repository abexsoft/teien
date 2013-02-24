require "teien/actor/actor_info"

class SinbadInfo < Teien::ActorInfo
  attr_accessor :object_name

  def initialize(actor_name)
    @actor_name = actor_name
    @object_name = nil
  end

  def self.create_actor(sinbad_info)
    Sinbad.new(sinbad_info)
  end

  Teien::ActorFactory::register_creator(self, self.method(:create_actor))
end

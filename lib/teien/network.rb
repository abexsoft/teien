require 'teien/remote_info'

module Teien

class Network < EM::Connection
  @@connections = Hash.new

  def initialize(event_router)
    @@event_router = event_router
  end

  def self.connections
    @@connections
  end

  include EM::P::ObjectProtocol

  def receive_object(obj)
    @@event_router.receive_event(obj, self)
  end

  def self.send_event_to_all(obj)
    @@connections.each_value { |c|
      c.connection.send_object(obj) if c.connection
    }
  end
end

end

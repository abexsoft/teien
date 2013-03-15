require 'teien/core/remote_info'

module Teien

class Network < EM::Connection
  @@connections = Hash.new
  @@event_router = nil

  def initialize(event_router)
    puts "network initialize"
    @@event_router = event_router
  end

  def self.connections
    @@connections
  end

  def self.add_dummy_connection(from)
    @@connections[from] = RemoteInfo.new(from)
  end

  include EM::P::ObjectProtocol


  def self.send_event_to_all(obj)
    @@connections.each_value { |c|
      c.connection.send_object(obj) if c.connection
    }
  end
end

end

require 'teien/network'

module Teien

class ClientNetwork < Teien::Network
  def post_init
  end

  def connection_completed
    puts "The connection is completed."
    @@connections[self] = RemoteInfo.new(self)
    @@event_router.connection_completed(self)
  end

  def unbind
    puts "The connection is closed."
    @@event_router.connection_unbinded(self)
    @@connections.delete(self)
  end
end

end

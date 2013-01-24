require 'teien/network'

module Teien

class ServerNetwork < Teien::Network
  def post_init
    puts "A client has connected."
    @@connections[self] = RemoteInfo.new(self)
    @@event_router.connection_binded(self)
  end

  def unbind
    puts "A client has unbinded."
    @@event_router.connection_unbinded(self)
    @@connections.delete(self)
  end
end

end

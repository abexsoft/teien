module Teien

class Network < EM::Connection
  @@connected_clients = Array.new
  @@garden = nil

  def initialize(garden)
    @@garden = garden
    @@garden.register_receiver(self)
  end

  def post_init
    puts "A client has connected."
    @@connected_clients.push(self)
    @@garden.receive_event(self, Event::ClientConnected.new)
  end

  def unbind
    puts "A client has unbinded."
    @@connected_clients.delete(self)
  end

  include EM::P::ObjectProtocol

  def receive_object(obj)
    @@garden.receive_event(self, obj)
#    @@event_router.notify(obj)
#    puts "A object is received"
#    obj.print
  end

  # Garden receiver
  def self.send_event(cli_id, event)
    @@connected_clients[cli_id].send_all(event)
  end

  def self.send_all(obj)
    @@connected_clients.each { |c|
      c.send_object(obj)
    }
  end
end

=begin
class ServerNetwork < EM::Connection
  @@connected_clients = Array.new

  def initialize(event_router)
    @event_router = event_router
    @event_router.register_receiver(Event::ToControllerGroup, self)
  end

  def receive_event(event)
    send_all(event)
  end

  def post_init
    puts "A client has connected."
    @@connected_clients.push(self)
    @event_router.notify(Event::ClientConnected.new)
  end

  def unbind
    puts "A client has unbinded."
    @@connected_clients.delete(self)
  end

  include EM::P::ObjectProtocol

  def receive_object(obj)
    @event_router.notify(obj)
#    puts "A object is received"
#    obj.print
  end

  def send_all(obj)
    @@connected_clients.each { |c|
      c.send_object(obj)
    }
  end
end

class ClientNetwork < EM::Connection
  def initialize(event_router)
    @event_router = event_router
    @event_router.register_receiver(Event::ToModelGroup, self)
  end

  def receive_event(event)
    send_object(event)
  end

  def connection_completed
    puts "The connection is completed."
  end

  def unbind
    puts "The connection is closed."
  end

  include EM::P::ObjectProtocol

  def receive_object(obj)
    @event_router.notify(obj)
  end
end

=end

end

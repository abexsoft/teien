module Teien

class ServerNetwork < EM::Connection
  @@connected_clients = Array.new

  def initialize(event_router)
    @event_router = event_router
    @event_router.register_receiver(Event::SyncEnv, self)
    @event_router.register_receiver(Event::SyncObject, self)
  end

  def receive_event(event)
    send_object(event)
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
    puts "A object is received"
    obj.print
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
#    @event_router.register_receiver(Event::KeyPressed, self)
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
    puts "A object is received"

    case obj
    when Event::SyncEnv
      @event_router.notify(obj)
    when Event::SyncObject
      @event_router.notify(obj)
    end
  end
end

end

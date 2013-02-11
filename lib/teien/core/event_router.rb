require "eventmachine"
require "teien/core/dispatcher"
require "teien/core/server_network"
require "teien/core/client_network"

module Teien

class EventRouter
  include Dispatcher

  attr_accessor :quit

  def initialize()
    super()
    @quit = false
  end

  def connection_binded(from)
    notify(:connection_binded, from)
  end

  def connection_completed(from)
    notify(:connection_completed, from)
  end

  def connection_unbinded(from)
    notify(:connection_unbinded, from)
  end

  def receive_event(event, from)
    notify(:receive_event, event, from)
  end

  # send a event to receivers and connections.
  # to = nil means to send the event to all connections.
  def send_event(event, to = nil)
    if to
      to.send_object(event)
    else
      Network::send_event_to_all(event)
    end
    notify(:receive_event, event, nil)
  end

  def start_server(ip = nil, port = 11922, tick_period = 0.001)
    notify(:setup)

    @last_time = 0
    EM.run do
      EM.add_periodic_timer(tick_period) do
        if @last_time == 0
          @last_time = Time.now.to_f 
          if ip == nil  
            # dummy connection for alone 
            Network::connections[nil] = RemoteInfo.new(nil)
            notify(:connection_binded, nil)
            notify(:connection_completed, nil)
          end
        else
          now = Time.now.to_f
          delta = now - @last_time
          @last_time = now

          notify(:update, delta)

          if @quit
            EM.stop 
            Teien::get_component("base_object_manager").finalize()
          end
        end
      end

      Signal.trap("INT")  { EM.stop; Teien::get_component("base_object_manager").finalize() }
      Signal.trap("TERM") { EM.stop; Teien::get_component("base_object_manager").finalize() }

      if (ip)
        EM.start_server(ip, port, ServerNetwork, self)
      end
    end
  end

  def connect_to_server(ip = nil, port = 11922, tick_period = 0.001)
    notify(:setup)

    @last_time = 0
    EM.run do
      EM.add_periodic_timer(tick_period) do
        if @last_time == 0
          @last_time = Time.now.to_f 
        else
          now = Time.now.to_f
          delta = now - @last_time
          @last_time = now

          notify(:update, delta)

          if @quit
            EM.stop 
            notify_reversely(:finalize)
#            Teien::get_component("base_object_manager").finalize()
          end
        end
      end
        
      Signal.trap("INT")  { EM.stop; notify_reversely(:finalize) }
      Signal.trap("TERM") { EM.stop; notify_reversely(:finalize) }

      if (ip)
        EM.connect(ip, port, ClientNetwork, self)
      end
    end
  end
end

end

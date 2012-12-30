require "eventmachine"
require "teien/event"
require "teien/network"

module Teien

##
# EventRouter routes events in this region and communicate with the other region routers.
#
# ====Usage
#  1. register a new event type name with registerEventType().
#  2. register a receiver object which receives the eventType with registerReceiver().
#     The receiver object must have action(event) method.
#  3. call notify(event) which issues the event.
#     The event must have eventType() method which returns event type name.
#
class EventRouter
  attr_accessor :connected_regions

  def initialize()
    @connected_regions = Array.new

    @event_type_receiver_hash = {}  # event_type => receivers

    @last_time = 0    
    @tick_event = Event::Tick.new(0)
    register_event_type(Event::Tick)
  end

  def finalize()
  end

  # eventmachine
  def send_all_regions(obj)
    @connected_regions.each { |c|
      c.send_object(obj)
    }
  end
  
  # event_type: the class name of a event.
  def register_event_type(event_type)
    @event_type_receiver_hash[event_type] = Array.new
  end

  ##
  # 
  # The event receiver must have action(anEvent) method.
  #
  def register_receiver(event_name, receiver)
    if (@event_type_receiver_hash.has_key?(event_name))
      @event_type_receiver_hash[event_name].push(receiver)
    else
      print "No such event type(#{event_name}) in EventRouter.\n"
      print "Use EventRouter::register_event_type(event_type) at first.\n"
    end
  end

  ##
  # The event notified by this method must have a event_type attribute and
  # the event_yype must be registered with register_event_type()
  #
  def notify(event)
    if (@event_type_receiver_hash.has_key?(event.class))
      @event_type_receiver_hash[event.class].each {|receiver|
        receiver.receive_event(event)
      }
    else
      print "No such event type(#{event.class}) in EventRouter.\n"
      print "Use EventRouter::register_event_type(event_type) at first.\n"
    end
  end

  def run()
    EM.run do
      Signal.trap("INT")  { EM.stop; self.finalize() }
      Signal.trap("TERM") { EM.stop; self.finalize() }

      EM.add_periodic_timer(0) do
        notify(@tick_event)
#        update(delta)
      end

#      EM.start_server("0.0.0.0", 11922, ServerNetwork, @event_router)
    end
  end

  # ip: string(ex. "0.0.0.0" means to accept all), 
  # port: num
  def start_region(ip, port)
    EM.run do
      Signal.trap("INT")  { EM.stop; self.finalize() }
      Signal.trap("TERM") { EM.stop; self.finalize() }
      
      EM.add_periodic_timer(0) do
        notify(@tick_event)
      end
      
      EM.start_server(ip, port, Network, self)
    end
  end

  def connect_to_region(ip, port)
    EM.run do
      # setting signals
      Signal.trap("INT")  { EM.stop; self.finalize() }
      Signal.trap("TERM") { EM.stop; self.finalize() }
      
      # main loop
      EM.add_periodic_timer(0) do
        notify(Event::Tick.new(@tick_event))
      end
      
      EM.connect('49.212.146.194', 11922, Network, self)
    end
  end
end

end 

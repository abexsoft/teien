require "teien/event.rb"

module Teien

##
# Route events
#
# ====Usage
#  1. register a new event type name with registerEventType().
#  2. register a receiver object which receives the eventType with registerReceiver().
#     The receiver object must have action(event) method.
#  3. call notify(event) which issues the event.
#     The event must have eventType() method which returns event type name.
#
class EventRouter
  def initialize()
    @event_type_receiver_hash = {}

  end
  
  # event_type: the class name of a event.
  def register_event_type(event_type)
    @event_type_receiver_hash[event_type] = Array.new
  end

  ##
  # 
  # The event receiver must have action(anEvent) method.
  #
  def register_receiver(event_type, receiver)
    if (@event_type_receiver_hash.has_key?(event_type))
      @event_type_receiver_hash[event_type].push(receiver)
    else
      print "No such event type in EventRouter.\n"
      print "Use EventRouter::register_event_type(event_type) at first.\n"
    end
  end

  ##
  # The event notified by this method must have a event_type attribute and
  # the event_yype must be registered with register_event_type()
  #
  def notify(event)
#    if (@event_type_receiver_hash.has_key?(event.event_type))
    if (@event_type_receiver_hash.has_key?(event.class))
      @event_type_receiver_hash[event.class].each {|receiver|
        receiver.receive_event(event)
      }
    else
      print "No such event type in EventRouter.\n"
      print "Use EventRouter::register_event_type(event_type) at first.\n"
    end
  end
end

end 

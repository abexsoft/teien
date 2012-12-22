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
    @event_type_receiver_hash = {}  # event_type => receivers
    @event_group_list = []          # groups
    @event_group_hash = {}          # event_type => groups

  end
  
  # event_type: the class name of a event.
  def register_event_type(event_type)
    @event_type_receiver_hash[event_type] = Array.new
    @event_group_hash[event_type] = Array.new
    @event_group_list.each {|grp|
      if (event_type.include?(grp))
        @event_group_hash[event_type].push(grp)
      end
    }
  end

  # event_group: 
  def register_event_group(event_group)
    @event_group_list.push(event_group)
    @event_type_receiver_hash[event_group] = Array.new
  end


  ##
  # 
  # The event receiver must have action(anEvent) method.
  #
  def register_receiver(event_name, receiver)
    if (@event_type_receiver_hash.has_key?(event_name))
      @event_type_receiver_hash[event_name].push(receiver)
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
    has_type = false
    if (@event_type_receiver_hash.has_key?(event.class))
      has_type = true

      @event_type_receiver_hash[event.class].each {|receiver|
        receiver.receive_event(event)

      }
    end

    if (@event_group_hash.has_key?(event.class))
      has_type = true
      @event_group_hash[event.class].each {|group|
        @event_type_receiver_hash[group].each {|receiver|
          receiver.receive_event(event)

        }
      }
    end
      
    unless (has_type)
      print "No such event type in EventRouter.\n"
      print "Use EventRouter::register_event_type(event_type) at first.\n"
    end
  end
end

end 

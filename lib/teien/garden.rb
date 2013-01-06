require "teien/garden_base.rb"
require "teien/network.rb"
require "teien/event.rb"

module Teien

class Garden < GardenBase
  def initialize()
    super
  end

  def run(ip = nil, port = 11922)
    return false unless setup()

    @last_time = 0
    EM.run do
      EM.add_periodic_timer(0) do
        @last_time = Time.now.to_f if @last_time == 0

        now_time = Time.now.to_f
        delta = now_time - @last_time
        @last_time = now_time

        unless update(delta)
          EM.stop
          self.finalize()
        end
      end

      Signal.trap("INT")  { EM.stop; self.finalize() }
      Signal.trap("TERM") { EM.stop; self.finalize() }

      if (ip)
        EM.start_server(ip, port, Network, self)
      end
    end
  end    

  def setup()
    @physics.setup(self)
    notify(:setup, self)
    return true
  end

  def update(delta)
    @physics.update(delta)
    @actors.each_value {|actor|
      actor.update(delta)
    }
    notify(:update, delta)
    return !@quit
  end

  # receive handler of Network.
  def receive_event(event, from)
    case event
    when Event::ClientConnected
      from.send_object(Event::SyncEnv.new(@gravity, @ambient_light_color, @sky_dome))      
      notify_objects()
    end
    notify(:receive_event, event, from)
  end

  def send_event(event, to = nil)
    if (to)
      to.send_object(event)
    else
      Network::send_all(event) if event.forwarding
      notify(:receive_event, event, nil)
    end
  end

  def notify_objects()
    @objects.each_value { |obj|
      notify_object(obj)
    }
  end

  def notify_object(obj)
    Network::send_all(Event::SyncObject.new(obj))
  end


  def finalize()
    @physics.finalize()
    @objects = {}
  end

end

end

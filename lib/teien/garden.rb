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
      EM.add_periodic_timer(0.01) do
        if @last_time == 0
          @last_time = Time.now.to_f 
        else
          now = Time.now.to_f
          delta = now - @last_time
          @last_time = now

          unless update(delta)
            EM.stop
            self.finalize()
          end
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
      notify_objects(from)
    end
    notify(:receive_event, event, from)
  end

  def send_event(event, to = nil)
    if (to)
      to.send_object(event)
    else
      Network::send_all(event)
    end
  end

  def notify_objects(to = nil)
    @objects.each_value { |obj|
      if to == nil
        Network::send_all(Event::SyncObject.new(obj))
      else
        to.send_object(Event::SyncObject.new(obj))
      end
    }
  end

  def finalize()
    @physics.finalize()
    @objects = {}
  end

end

end

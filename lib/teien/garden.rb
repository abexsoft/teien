require "teien/garden_base.rb"
require "teien/network.rb"
require "teien/event.rb"

module Teien

class Garden < GardenBase

  def initialize()
    super
  end

  #
  # mainloop
  #
  def run(ip = nil, port = 11922)
    return false unless setup()

    @last_time = 0
    EM.run do
      EM.add_periodic_timer(0) do
        @last_time = Time.now.to_f if @last_time == 0

        now_time = Time.now.to_f
        delta = now_time - @last_time
        @last_time = now_time

        update(delta)
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
=begin
    @objects.each_value {|obj|
      obj.update(delta)
    }
=end
    notify(:update, delta)
    return true
  end

  def receive_event(con, event)
    case event
    when Event::ClientConnected
      puts "A client is connected!"
      con.send_object(Event::SyncEnv.new(@gravity, @ambient_light_color, @sky_dome))      
      notify_objects()
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

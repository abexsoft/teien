require 'teien'
require_relative "model"
require "teien/application/server_application"

include Teien

class Server < ServerApplication
  include Model

  def initialize(sync_period = 0.3)
    super(sync_period)

    @event_router.register_receiver(self)
  end

  def setup()
    model_setup()
  end

  def connection_binded(from)
    model_connection_binded(from)
  end

  def connection_unbinded(from)
    model_connection_unbinded(from)
  end

  def receive_event(event, from)
    model_receive_event(event, from)
  end

end

Server.new.start_server("0.0.0.0", 11922)

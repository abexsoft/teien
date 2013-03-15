require 'teien'
require "teien/application/server_application"
require_relative 'model'

include Teien

class Server < ServerApplication
  include Model

  def initialize()
    super(0.3)

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

  ##
  # EventRouter handlers
  #

  def receive_event(event, from)
    model_receive_event(event, from)
  end
end

Server.new.start_server("0.0.0.0", 11922)

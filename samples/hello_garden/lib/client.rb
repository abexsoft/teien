require "teien"
require_relative "ui"
require "teien/application/proxy_application"

include Teien

class Client < ProxyApplication
  include Ui

  def initialize
    super

    require 'teien/ui/user_interface'
    @ui = Teien::UserInterface.new()
    Teien::register_component("user_interface", @ui )

    @event_router.register_receiver(self)
    @ui.register_receiver(self)
  end

  ##
  # EventRouter handlers
  #

  def setup
    ui_setup()

  end

  def connection_completed(from)
    ui_connection_completed(from)
  end

  def update(delta)
    ui_update(delta)
    @camera_mover.update(delta)
  end

end

Client.new.connect_to_server("0.0.0.0", 11922)

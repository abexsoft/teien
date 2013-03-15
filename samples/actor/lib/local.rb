require 'teien'
require "teien/application/local_application"
require_relative 'model'
require_relative 'ui'

include Teien

class Local < LocalApplication
  include Model
  include Ui

  def initialize(sync_period = 0)
    super(sync_period)

    require 'teien/ui/user_interface'
    @ui = Teien::UserInterface.new()
    Teien::register_component("user_interface", @ui )

    @event_router.register_receiver(self)
    @ui.register_receiver(self)

    @first_update = true
  end

  def setup()
    model_setup()
    ui_setup()
  end

  def connection_binded(from)
    puts "connection_binded"
    model_connection_binded(from)
  end

  def connection_unbinded(from)
    puts "connection_unbinded"
    model_connection_unbinded(from)
  end

  def connection_completed(from)
    puts "connection_completed"
    ui_connection_completed(from)
  end

  ##
  # EventRouter handlers
  #

  def update(delta)
    if @first_update
      @first_update = false
    end

    ui_update(delta)
  end

  def receive_event(event, from)
    model_receive_event(event, from)
    ui_receive_event(event, from)
  end
end

Local.new.start_application

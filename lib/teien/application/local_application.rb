require "teien/application/server_application"

module Teien

class LocalApplication < ServerApplication
  def start_application
    @event_router.start_application()
  end

end

end

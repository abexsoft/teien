require_relative "world"

module Teien
  class Server
    def initialize(app_klass)
      @world = nil
      @app_klass = app_klass
    end

    def open(ws)
      ws.on :open do |event|
        p [:open, ws.object_id, ws.url, ws.version, ws.protocol]

        unless @world
          @world = Teien::World.new(@app_klass)
          @world.run
        end
        
        @world.connected(ws, event)
      end
      
      ws.on :message do |event|
        p [:message, event.data]
        @world.receive_message(ws, event)
      end
      
      ws.on :close do |event|
        p [:close, ws.object_id, event.code]
        @world.disconnected(ws, event)

        @world = nil if @world.clients.size <= 0
      end

    end
  end
end

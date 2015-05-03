require 'json'
require_relative './physics'

module Teien
  class World
    SYNC_PERIOD = 0.5
    attr_accessor :env    
    attr_accessor :clients
    attr_accessor :actors

    def initialize(app_klass)
      @update_period = 0
      @update_timer_thread = nil

      @env = {
        :world_aabb_min => {
          :x => -3000,
          :y =>-500,
          :z => -3000
        },
        :world_aabb_max => {
          :x => 3000,
          :y => 500,
          :z => 3000
        },
        :max_proxies => 1024 * 4,
        :gravity => {
          :x => 0,
          :y => -9.8,
          :z => 0
        }
      }

      # network
      @clients = []

      # actor
      @actors = {}

      # physics
      @physics = Teien::Physics.new(self)

      @app = app_klass.new(self)
    end

    def add_actor(actor)
      if @actors[actor.name]
        Teien::log.info("There is already an actor which has the name[#{actor.name}].")
        return false
      else
        actor.setup(@physics)
        @actors[actor.name] = actor
        return true
      end
    end

    def send_actors(ws)
      actors = []
      @actors.each{|k, v|
        actors << v.to_hash
      }
      
      actors_event = {}
      actors_event[:type] = "actors"
      actors_event[:data] = actors

      puts actors_event.to_json
      ws.send(actors_event.to_json)
    end

    #
    # events
    #

    def setup()
      @physics.setup(@env)
      @app.setup if @app.respond_to?(:setup)
      set_update_period(1.0 / 60.0)
      @sync_left_time = SYNC_PERIOD
    end

    def connected(ws, event)
      @clients << ws
      Teien::log.debug("Connection's num: #{@clients.size}")

      @app.connected(ws, event) if @app.respond_to?(:connected)
      @clients.each { |client| 
        event = {:type => "connected", :total_clients => @clients.size}
        client.send (event.to_json)
      }

      send_actors(ws)
    end

    def disconnected(ws, event)
      @clients.delete(ws)
      Teien::log.debug("Connection's num: #{@clients.size}")

      @app.disconnected(ws, event) if @app.respond_to?(:disconnected)
      @clients.each { |client| 
        event = {:type => "disconnected", :total_clients => @clients.size}
        client.send (event.to_json)
      }

      ws = nil
    end

    def receive_message(ws, event)
      @app.receive_message(ws, event) if @app.respond_to?(:receive_message)
=begin
      @clients.each { |client| 
        client.send event.data
      }
=end
    end

    def update (delta)
      @physics.update(delta)
      @app.update(delta) if @app.respond_to?(:update)

      @sync_left_time -= delta
      if @sync_left_time < 0
        @clients.each { |client|
          send_actors(client)
        }
        @sync_left_time = SYNC_PERIOD
      end
        
    end

    def run()
      Teien::log.info("Starting up a teien server.")
      setup()
    end

    private

    def set_update_period(period)
      @update_period = period

      if @update_timer_thread
        @update_timer_thread.exit
        @update_timer_thread = nil
      end

      return if @update_period <= 0

      @update_timer_thread = Thread.new {
        now = 0
        loop do
          start_time = Time.now
          update(start_time - now) unless now == 0
          now = Time.now
          elapsed = now - start_time
          sleep([@update_period - elapsed, 0].max)
        end
      }
    end
  end
end

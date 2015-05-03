require "sinatra/reloader"
require 'faye/websocket'

require_relative '../models/sample_app'

class Sample < Sinatra::Base
  KEEPALIVE_TIME = 15 # in seconds

  configure :development do
    register Sinatra::Reloader
  end
  
  configure do
    root_folder = File.dirname(File.expand_path(__FILE__)) + "/../../../"
    set :public_folder , root_folder + 'public/'
    set :views, root_folder + 'apps/sample/views/'
    set :s1, Teien::Server.new(SampleApp)
  end
  
  get "/sample" do
    if Faye::WebSocket.websocket?(request.env)
      puts "websocket incoming"
      ws = Faye::WebSocket.new(request.env, nil, {ping: KEEPALIVE_TIME })
      settings.s1.open(ws)
      
      # Return async Rack response
      ws.rack_response        
    else
      erb :sample
    end
  end
end

require "sinatra/reloader"

class Root < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end
  
  configure do
    root_folder = File.dirname(File.expand_path(__FILE__)) + "/../../../"
    set :views, root_folder + 'apps/root/views/'
  end
  
  get "/" do
    @http_host = request.env["HTTP_HOST"]
    erb :index
  end
end

require 'sinatra/base'

require_relative 'root/controllers/root'
require_relative 'sample/controllers/sample'

class Routes < Sinatra::Base
  use Root
  use Sample
end

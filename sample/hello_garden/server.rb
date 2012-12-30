require 'teien'

require_relative './app/model'

Teien::start_server_garden("0.0.0.0", 11922, HelloGardenModel)

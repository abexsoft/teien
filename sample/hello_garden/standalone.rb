require 'teien'

require_relative './app/model'
require_relative './app/controller'


Teien::start_standalone_garden(HelloGardenModel, HelloGardenController)

require 'teien'

require_relative './app/controller'

Teien::start_client_garden("0.0.0.0", 11922, ActorController)
#Teien::start_client_garden('49.212.146.194', 11922, ActorController)

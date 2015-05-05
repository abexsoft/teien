require 'logger'
require 'faye/websocket'

require_relative "teien/utils"
require_relative "teien/actor"
require_relative "teien/server"
require_relative 'teien/actors/sphere_actor'
require_relative 'teien/actors/box_actor'
require_relative 'teien/actors/ghost_actor'

module Teien
  @@log = Logger.new(STDOUT)
  @@log.level = Logger::DEBUG

  @@log.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime.strftime("%Y-%m-%d %H:%M:%S")}] #{severity} #{progname}: #{msg}\n"
  end

  def self.log
    @@log
  end
end


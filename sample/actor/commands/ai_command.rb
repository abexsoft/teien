module Teien
  class AiCommand
    def self.ai_command(argv)
=begin
      require "teien/proxy_garden.rb"
      require_relative "ai/actor_ai.rb"

      ip = ARGV[1] ? ARGV[1] : "0.0.0.0"
      port = ARGV[2] ? ARGV[2].to_i : 11922

      garden = Teien::ProxyGarden.new()
      ai = ActorAi.new(garden)

      garden.run(ip, port)
=end
    end
  end

  Teien::Launcher::register_command("ai", AiCommand.method(:ai_command))
end

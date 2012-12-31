require 'teien/event.rb'

module Event
  class ShotBox < EventBase
    attr_accessor :pos
    attr_accessor :dir
    def initialize(pos, dir)
      @pos = pos
      @dir = dir
    end
  end
end

module Event
  class ShotBox 
    include Event::ToModelGroup

    attr_accessor :pos
    attr_accessor :dir
    def initialize(pos, dir)
      @pos = pos
      @dir = dir
    end
  end
end

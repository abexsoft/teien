module Teien::Event::Browser
  class KeyPressed
    attr_accessor :key

    def initialize(key)
      @key = key
    end
  end

  class KeyReleased
    attr_accessor :key

    def initialize(key)
      @key = key
    end
  end
end

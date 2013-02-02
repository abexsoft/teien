module Teien
  @@components = Hash.new()

  def self.register_component(name, component)
    @@components[name] = component
  end

  def self.get_component(name)
    return @@components[name]
  end
end

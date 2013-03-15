module Teien
  @@components = Hash.new()

  def self.register_component(name, component)
    @@components[name] = component
  end

  def self.get_component(name)
    component = @@components[name]
    return component if component
    raise RuntimeError, "There is no such component registered: '#{name}'."
  end
end

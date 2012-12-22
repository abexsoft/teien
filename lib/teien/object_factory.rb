require 'teien/object_factory_base'

module Teien

class ObjectFactory < ObjectFactoryBase
  def initialize(garden)
    super
  end

  def create_object(name, object_info, physics_info)
    obj = GardenObject.new(@garden)
    obj.name = name
    obj.object_info = object_info
    obj.physics_info = physics_info    
    create_object_common(obj)
    return obj
  end

  def create_light_object(obj)
    add_light_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end

  def create_floor_object(obj)
    add_floor_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end

  def create_box_object(obj)
    add_box_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end

  def create_sphere_object(obj)
    add_sphere_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end

  def create_capsule_object(obj)
    add_capsule_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end

  def create_cone_object(obj)
    add_cone_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end

  def create_cylinder_object(obj)
    add_cylinder_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end

  def create_meshBB_object(obj)
    add_meshBB_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end

=begin
  def create_mesh_object(obj)
    add_mesh_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end
=end

end

end

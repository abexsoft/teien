require 'teien/object_factory_base'
require 'teien/proxy_garden_object'

module Teien

class ProxyObjectFactory < ObjectFactoryBase
  def initialize(garden)
    super
  end

  def create_object(name, object_info, physics_info)
    obj = ProxyGardenObject.new(@garden)
    obj.name = name
    obj.object_info = object_info
    obj.physics_info = physics_info    
    create_object_common(obj)
  end

  def create_object_from_event(event)
    obj = ProxyGardenObject.new(@garden)
    obj.name = event.name
    obj.object_info = event.object_info
    obj.physics_info = event.physics_info    
    create_object_common(obj)

    obj.set_position(event.pos)
    obj.set_linear_velocity(event.linear_vel)
    obj.set_angular_velocity(event.angular_vel)
    obj.set_rotation(event.quat)

=begin
    obj.set_position(Vector3D.new(event.pos[0],
                                  event.pos[1],
                                  event.pos[2]))
    obj.set_linear_velocity(Vector3D.new(event.linear_vel[0],
                                         event.linear_vel[1],
                                         event.linear_vel[2]))
    obj.set_angular_velocity(Vector3D.new(event.angular_vel[0],
                                          event.angular_vel[1],
                                          event.angular_vel[2]))
    obj.set_rotation(Quaternion.new(event.quat[0],
                                    event.quat[1],
                                    event.quat[2],
                                    event.quat[3]))
=end
  end

  def create_light_object(obj)
    add_light_object_physics(obj)
    add_light_object_view(obj)
    @garden.add_object(obj)
    return obj
  end

  def create_floor_object(obj)
    add_floor_object_view(obj)
    add_floor_object_physics(obj)
    @garden.add_object(obj)
  end

  def create_box_object(obj)
    add_box_object_view(obj)
    add_box_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end

  def create_sphere_object(obj)
    add_sphere_object_view(obj)
    add_sphere_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end

  def create_capsule_object(obj)
    add_capsule_object_view(obj)
    add_capsule_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end

  def create_cone_object(obj)
    add_cone_object_view(obj)
    add_cone_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end

  def create_cylinder_object(obj)
    add_cylinder_object_view(obj)
    add_cylinder_object_physics(obj)
    @garden.add_object(obj)
    return obj
  end

  def create_meshBB_object(obj)
    add_meshBB_object_view(obj)
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

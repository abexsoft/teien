require_relative "../physics_object_factory"

module Teien

class LightObjectInfo < ObjectInfo
  POINT = Ogre::Light::LT_POINT
  DIRECTIONAL = Ogre::Light::LT_DIRECTIONAL
  SPOTLIGHT = Ogre::Light::LT_SPOTLIGHT

  attr_accessor :type
  attr_accessor :diffuse_color
  attr_accessor :specular_color
  attr_accessor :direction

  def initialize(type,
                 diffuse_color = Color.new(1.0, 1.0, 1.0),
                 specular_color = Color.new(0.25, 0.25, 0),
                 direction = Vector3D.new( -1, -1, -1 ))
    super()
    @usePhysics = false
    @type = type
    @diffuse_color = diffuse_color
    @specular_color = specular_color
    @direction = direction
  end

  def self.create_physics_object(obj, physics)
    physics_object = PhysicsObject.new(physics)
    cShape = Bullet::BtSphereShape.new(0.1)
    inertia = Bullet::BtVector3.new()
    cShape.calculate_local_inertia(0, inertia)
    obj.physics_info = PhysicsInfo.new(0)
    physics_object.set_rigid_body(obj, cShape, inertia)
    return physics_object
  end

  PhysicsObjectFactory::set_creator(self, self.method(:create_physics_object))
end

end

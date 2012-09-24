require "teien/tools.rb"

class LightObject
  POINT = Ogre::Light::LT_POINT
  DIRECTIONAL = Ogre::Light::LT_DIRECTIONAL
  SPOTLIGHT = Ogre::Light::LT_SPOTLIGHT

  attr_accessor :name
  attr_accessor :light

  def initialize(garden, name)
    @garden = garden
    @name = name
    @light = @garden.view.scene_mgr.createLight(@name);
  end

  def set_type(type)
    @light.setType(type)
  end

  def set_diffuse_color(color)
    @light.setDiffuseColour(color);
  end

  def set_specular_color(color)
    @light.setSpecularColour(color)
  end

  def set_position(vec)
    @light.setPosition(Vector3D.to_ogre(vec));
  end

  def set_direction(vec)
    @light.setDirection(Vector3D.to_ogre(vec));
  end
end

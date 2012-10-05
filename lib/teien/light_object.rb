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
    @light = @garden.view.scene_mgr.create_light(@name);
  end

  def set_type(type)
    @light.set_type(type)
  end

  def set_diffuse_color(color)
    @light.set_diffuse_colour(color);
  end

  def set_specular_color(color)
    @light.set_specular_colour(color)
  end

  def set_position(vec)
    @light.set_position(Vector3D.to_ogre(vec));
  end

  def set_direction(vec)
    @light.set_direction(Vector3D.to_ogre(vec));
  end
end

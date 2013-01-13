module Teien

class ObjectInfo
  attr_accessor :use_physics
  attr_accessor :use_view

  def initialize()
    @use_physics = true
    @use_view = true
  end
end

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
end

class MeshBBObjectInfo  < ObjectInfo
  attr_accessor :mesh_path
  attr_accessor :size          # Loading mesh only: bounding box size
  attr_accessor :scale         # Loading mesh only: scales mesh
  attr_accessor :view_offset    # Loading mesh only: offset of Mesh
  attr_accessor :view_rotation  # Loading mesh only: rotation offset of Mesh
  attr_accessor :physics_offset # Loading mesh only: offset of collision Box 
  attr_accessor :material_name

  def initialize(mesh_path, size, scale = Vector3D.new(1, 1, 1),
                 view_offset = Vector3D.new(0, 0, 0),
                 view_rotation = Quaternion.new(0, 0, 0, 1.0),
                 physics_offset = Vector3D.new(0, 0, 0))
    super()
    @size = size
    @mesh_path = mesh_path
    @scale = scale
    @view_offset = view_offset
    @view_rotation = view_rotation
    @physics_offset = physics_offset
    @material_name = nil
  end
end

class MeshObjectInfo  < ObjectInfo
  attr_accessor :mesh_path
  attr_accessor :scale         # Loading mesh only: scales mesh
  attr_accessor :view_offset    # Loading mesh only: offset of Mesh
  attr_accessor :view_rotation  # Loading mesh only: rotation offset of Mesh
  attr_accessor :physics_offset # Loading mesh only: offset of collision Box 
  attr_accessor :material_name

  def initialize(mesh_path, scale = Vector3D.new(1, 1, 1),
                 view_offset = Vector3D.new(0, 0, 0),
                 view_rotation = Quaternion.new(0, 0, 0, 1.0),
                 physics_offset = Vector3D.new(0, 0, 0))
    super()
    @mesh_path = mesh_path
    @scale = scale
    @view_offset = view_offset
    @view_rotation = view_rotation
    @physics_offset = physics_offset
    @material_name = nil
  end
end

class FloorObjectInfo < ObjectInfo
  attr_accessor :width
  attr_accessor :height
  attr_accessor :depth
  attr_accessor :num_seg_x
  attr_accessor :num_seg_y
  attr_accessor :u_tile
  attr_accessor :v_tile
  attr_accessor :material_name

  def initialize(width, height, depth = 0.5, num_seg_x = 1, num_seg_y = 1, u_tile = 1.0, v_tile = 1.0)
    super()
    @width   = width
    @height  = height
    @depth   = depth
    @num_seg_x = num_seg_x
    @num_seg_y = num_seg_y
    @u_tile   = u_tile
    @v_tile   = v_tile
    @material_name = nil
  end
end

class BoxObjectInfo < ObjectInfo
  attr_accessor :size
  attr_accessor :num_seg_x
  attr_accessor :num_seg_y
  attr_accessor :num_seg_z
  attr_accessor :u_tile
  attr_accessor :v_tile
  attr_accessor :material_name

  def initialize(size, num_seg_x = 1, num_seg_y = 1, num_seg_z = 1, u_tile = 1.0, v_tile = 1.0)
    super()
    @size = size
    @num_seg_x = num_seg_x
    @num_seg_y = num_seg_y
    @num_seg_z = num_seg_z
    @u_tile   = u_tile
    @v_tile   = v_tile
    @material_name = nil
  end
end

class SphereObjectInfo < ObjectInfo
  attr_accessor :radius
  attr_accessor :num_rings
  attr_accessor :num_segments
  attr_accessor :u_tile
  attr_accessor :v_tile
  attr_accessor :material_name

  def initialize(radius, num_rings = 16, num_segments = 16, u_tile = 1.0, v_tile = 1.0)
    super()
    @radius = radius
    @num_rings = num_rings
    @num_segments = num_segments
    @u_tile = u_tile
    @v_tile = v_tile
    @material_name = nil
  end
end

class CapsuleObjectInfo < ObjectInfo
  attr_accessor :radius
  attr_accessor :height
  attr_accessor :num_rings
  attr_accessor :num_segments
  attr_accessor :num_seg_height
  attr_accessor :u_tile
  attr_accessor :v_tile
  attr_accessor :material_name

  def initialize(radius, height, num_rings = 8, num_segments = 16, num_seg_height = 1, u_tile = 1.0, v_tile = 1.0)
    super()
    @radius = radius
    @height = height
    @num_rings = num_rings
    @num_segments = num_segments
    @num_seg_height = num_seg_height
    @u_tile = u_tile
    @v_tile = v_tile
    @material_name = nil
  end
end

class ConeObjectInfo < ObjectInfo
  attr_accessor :radius
  attr_accessor :height
  attr_accessor :num_seg_base
  attr_accessor :num_seg_height
  attr_accessor :u_tile
  attr_accessor :v_tile
  attr_accessor :material_name

  def initialize(radius, height, num_seg_base = 16, num_seg_height = 1, u_tile = 1.0, v_tile = 1.0)
    super()
    @radius = radius
    @height = height
    @num_seg_base = num_seg_base
    @num_seg_height = num_seg_height
    @u_tile = u_tile
    @v_tile = v_tile
    @material_name = nil
  end
end

class CylinderObjectInfo < ObjectInfo
  attr_accessor :radius
  attr_accessor :height
  attr_accessor :capped
  attr_accessor :num_seg_base
  attr_accessor :num_seg_height
  attr_accessor :u_tile
  attr_accessor :v_tile
  attr_accessor :material_name

  def initialize(radius, height, capped = true, num_seg_base = 16, num_seg_height = 1, u_tile = 1.0, v_tile = 1.0)
    super()
    @radius = radius
    @height = height
    @capped = capped
    @num_seg_base = num_seg_base
    @num_seg_height = num_seg_height
    @u_tile = u_tile
    @v_tile = v_tile
    @material_name = nil
  end
end

end

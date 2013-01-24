module Teien

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

  # Setting a collision shape and a rigid body of Bullet.
  def self.create_physics_object(obj, physics)
    physics_object = PhysicsObject.new(physics)
    cShape = Bullet::BtBoxShape.new(Vector3D.new(obj.object_info.width, 
                                                 obj.object_info.depth, 
                                                 obj.object_info.height))
    physics_object.set_rigid_body(obj, cShape, 
                                  Vector3D.new(0, 0, 0), 
                                  Vector3D.new(0.0, -obj.object_info.depth, 0.0))

    obj.object_info.use_physics = true

    return physics_object
  end

  # Setting an entity and a node of Ogre3d.
  def self.create_view_object(obj, view)
    normal = Ogre::Vector3.new(0, 1, 0)
    up = Ogre::Vector3.new(0, 0, 1)
    Ogre::MeshManager::get_singleton().create_plane(obj.name, 
                                                    Ogre::ResourceGroupManager.DEFAULT_RESOURCE_GROUP_NAME,
                                                    Ogre::Plane.new(normal, 0), 
                                                    obj.object_info.width * 2.0, 
                                                    obj.object_info.height * 2.0, 
                                                    obj.object_info.num_seg_x, 
                                                    obj.object_info.num_seg_y, 
                                                    true, 1, 
                                                    obj.object_info.u_tile, 
                                                    obj.object_info.v_tile, up)
    entity = view.scene_mgr.create_entity(obj.name, obj.name)
    entity.set_cast_shadows(true)
    entity.set_material_name(obj.object_info.material_name)

    view_object = ViewObject.new(view)
    view_object.set_scene_node(entity)

    obj.object_info.use_view = true

    return view_object
  end

  PhysicsObjectFactory::set_creator(self, self.method(:create_physics_object))
  ViewObjectFactory::set_creator(self, self.method(:create_view_object))
end

end

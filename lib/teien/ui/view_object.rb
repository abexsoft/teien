require "teien/animation/animation_operator.rb"

module Teien

class ViewObject
  # Ogre3D accessor
  ## center of view objects(sceneNode) and kept to equal with the rigid_body position.
  attr_accessor :pivot_scene_node 
  attr_accessor :scene_node
  attr_accessor :entity
  attr_accessor :animation_operators

  attr_accessor :object

  def initialize(view)
    @view = view
    @pivot_scene_node = nil
    @scene_node = nil
    @entity = nil
    @animation_operators = Hash.new
    @attached_objects = Hash.new
    @base_object_manager = Teien::get_component("base_object_manager")
  end

  def finalize()
    @pivot_scene_node.remove_child(@scene_node)
    @view.scene_mgr.destroySceneNode(@scene_node)
    @view.scene_mgr.get_root_scene_node.remove_child(@pivot_scene_node)
    @view.scene_mgr.destroySceneNode(@pivot_scene_node)
    @view.scene_mgr.destroyEntity(@entity)
  end

  def update_attached_objects(view)
    # attached
    @object.attached_objects.each_pair {|key, info|
      unless @attached_objects[key]
        attached_object = @base_object_manager.objects[info.object_name]
        attached_entity = view.objects[attached_object.name].entity
        attached_scene_node = view.objects[attached_object.name].scene_node

        puts "attached: #{info.bone_name}, #{attached_entity}"

        attached_scene_node.detach_object(attached_entity)
        tag = @entity.attach_object_to_bone(info.bone_name, attached_entity)
#        @manager.physics.dynamics_world.remove_rigid_body(obj.rigid_body)
        attached_object.mode = Teien::BaseObject::MODE_ATTACHED
        @attached_objects[key] = info
      end
    }

    # detached
    @attached_objects.each_pair {|key, info|
      unless @object.attached_objects[key]
        detached_object = @base_object_manager.objects[info.object_name]
        detached_entity = view.objects[detached_object.name]
        detached_scene_node = view.objects[detached_object.name].scene_node

        @entity.detach_object_from_bone(detached_entity)
        detached_scene_node.attach_object(obj.entity)
=begin
        if obj.physics_info.collision_filter
          @manager.physics.dynamics_world.add_rigid_body(obj.rigid_body, 
                                                         obj.physics_info.collision_filter.group,
                                                         obj.physics_info.collision_filter.mask)
        else
          @manager.physics.dynamics_world.add_rigid_body(obj.rigid_body)
        end
=end
        detached_object.mode = Teien::BaseObject::MODE_FREE
        @attached_objects.delete(key)
      end
    }


  end

  def update_animation(delta, animation)
    animation.operators.each_pair{|key, value|
      unless @animation_operators[key]
        @entity.get_skeleton().set_blend_mode(animation.blend_mode)
        ani_ope = AnimationOperator.new(@entity)
        ani_ope.init(value.name, value.loop)
        @animation_operators[key] = ani_ope
      end

      if (value.name != @animation_operators[key].name ||
          value.loop != @animation_operators[key].loop)
        @animation_operators[key].play(value.name, value.loop)
      end
      @animation_operators[key].add_time(delta * value.speed)
    }
  end

  #
  # The offset changes the local position of the created scene_node in Object.
  #
  def set_scene_node(entity, offset = Vector3D.new(0, 0, 0), rotate = Quaternion.new(0, 0, 0, 1.0))
    if (@pivot_scene_node == nil)
      @pivot_scene_node = @view.scene_mgr.get_root_scene_node().create_child_scene_node()
    end
    @scene_node = @pivot_scene_node.create_child_scene_node(Vector3D.to_ogre(offset), 
                                                            Quaternion.to_ogre(rotate))
    @pivot_scene_node.instance_variable_set(:@child, @scene_node) # prevent this from GC.

    if entity
      @scene_node.attach_object(entity)
      @entity = entity
    end

    return @scene_node
  end

  #
  # handlers of BaseObject

  def set_position(aPos)
    if @pivot_scene_node
      @pivot_scene_node.set_position(aPos.x, aPos.y, aPos.z)
    else
      # object_info.class == LightObjectInfo
      @entity.set_position(Vector3D.to_ogre(aPos))
    end
  end

  def set_world_transform(transform)
    newPos = transform.get_origin()
    newRot = transform.get_rotation()
    # puts "newRot(#{id}: #{newRot.x}, #{newRot.y}, #{newRot.z}, #{newRot.w})"
    # puts "newPos(#{id}: #{newPos.x}, #{newPos.y}, #{newPos.z})"
    
    return if (newRot.x.nan?)
    
    @pivot_scene_node.set_position(newPos.x, newPos.y, newPos.z) 
    @pivot_scene_node.set_orientation(newRot.w, newRot.x, newRot.y, newRot.z)
  end

  def set_rotation(rot)
    @pivot_scene_node.set_orientation(Quaternion.to_ogre(rot))
  end
end

end

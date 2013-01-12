require "teien/animation_operator.rb"

module Teien

class ViewObject
  # Ogre3D accessor
  ## center of view objects(sceneNode) and kept to equal with the rigid_body position.
  attr_accessor :pivot_scene_node 
  attr_accessor :scene_node
  attr_accessor :entity
  attr_accessor :animation_operators

  def initialize(view)
    @view = view
    @pivot_scene_node = nil
    @scene_node = nil
    @entity = nil
    @animation_operators = Hash.new
  end

  def finalize()
    @pivot_scene_node.remove_child(@scene_node)
    @view.scene_mgr.destroySceneNode(@scene_node)
    @view.scene_mgr.get_root_scene_node.remove_child(@pivot_scene_node)
    @view.scene_mgr.destroySceneNode(@pivot_scene_node)
    @view.scene_mgr.destroyEntity(@entity)
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
  
end

end

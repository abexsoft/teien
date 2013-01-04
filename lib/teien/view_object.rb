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
    @animation_operators = Array.new
  end

  def finalize()
    @pivot_scene_node.remove_child(@scene_node)
    @view.scene_mgr.destroySceneNode(@scene_node)
    @view.scene_mgr.get_root_scene_node.remove_child(@pivot_scene_node)
    @view.scene_mgr.destroySceneNode(@pivot_scene_node)
    @view.scene_mgr.destroyEntity(@entity)
  end

  def update_animation(delta, animation)
    animation.operators.each_with_index {|operator, i|
      unless @animation_operators[i]
        @entity.get_skeleton().set_blend_mode(animation.blend_mode)
        ani_ope = AnimationOperator.new(@entity)
        ani_ope.init(operator.name, operator.loop)
        @animation_operators.push(ani_ope)
      end

      if (operator.name != @animation_operators[i].name ||
          operator.loop != @animation_operators[i].loop)
        @animation_operators[i].play(operator.name, operator.loop)
      end
      @animation_operators[i].add_time(delta * operator.speed)
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

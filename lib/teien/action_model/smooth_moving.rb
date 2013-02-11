module Teien

class SmoothMoving
  ACCELERATION = 5.0
  TURN_SPEED = 500.0

  attr_accessor :target_object_name
  attr_accessor :acceleration
  attr_accessor :turn_speed
  attr_accessor :movable

  def initialize(target_object_name)
    @target_object_name = target_object_name
    @target_object = Teien::get_component("base_object_manager").objects[target_object_name]
    @acceleration = ACCELERATION
    @turn_speed = TURN_SPEED
    @move_dir = Ogre::Vector3.new(0, 0, 0)
    @forward_dir = Ogre::Vector3.new(0, 0, 0)
    @zero_vector = Vector3D.new(0, 0, 0)
    clear_action()
    @movable = true

    @event_router = Teien::get_component("event_router")
  end

  def clear_action()
    @forward = false
    @backward = false
    @left = false
    @right = false
  end

  def moving?()
    return (@forward || @backward || @left || @right)
  end

  def set_acceleration(accel)
    @acceleration = accel
  end

  def set_turn_speed(turn_speed)
    @turn_speed = turn_speed
  end

  #
  # This direction is the forward.
  #
  def set_forward_direction(forward_dir)
    @forward_dir = forward_dir
  end

  def move_forward(bool)
    @forward = bool
  end

  def move_backward(bool)
    @backward = bool
  end

  def move_left(bool)
    @left = bool
  end

  def move_right(bool)
    @right = bool
  end


  def update_target(delta)
    @move_dir.x = 0
    @move_dir.y = 0
    @move_dir.z = 0

    # update target's acceleration
    if (@forward)
      @move_dir += Ogre::Vector3.new(@forward_dir.x, @forward_dir.y, @forward_dir.z)
    end
    if (@backward)
      @move_dir += Ogre::Vector3.new(-@forward_dir.x, -@forward_dir.y, -@forward_dir.z)
    end
    if (@left)
      @move_dir += Ogre::Vector3.new(@forward_dir.z, 0,  -@forward_dir.x)
    end
    if (@right)
      @move_dir += Ogre::Vector3.new(-@forward_dir.z, 0, @forward_dir.x)
    end

    @move_dir.y = 0
    @move_dir.normalise()

    if (@movable)
      newAcc = @move_dir * @acceleration
      @target_object.set_acceleration(Vector3D.to_self(newAcc))
    else
      @target_object.set_acceleration(@zero_vector)
    end

    # update target's direction
    toGoal = Vector3D.to_ogre(-@target_object.get_orientation().z_axis()).get_rotation_to(@move_dir)
    yawToGoal = toGoal.get_yaw().value_degrees()
    yawAtSpeed = yawToGoal / yawToGoal.abs * delta * @turn_speed

    if (yawToGoal < 0) 
      yawToGoal = [0, [yawToGoal, yawAtSpeed].max].min
    elsif (yawToGoal > 0) 
      yawToGoal = [0, [yawToGoal, yawAtSpeed].min].max
    end

    @target_object.yaw(Ogre::Degree.new(yawToGoal).value_radians())
  end
end

end

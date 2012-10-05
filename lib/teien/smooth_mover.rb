class SmoothMover
  ACCELERATION = 5.0
  TURN_SPEED = 500.0

  attr_accessor :acceleration
  attr_accessor :turnSpeed
  attr_accessor :movable

  def initialize(targetObject)
    @targetObject = targetObject

    @acceleration = ACCELERATION
    @turnSpeed = TURN_SPEED

    clearAction()

    @movable = true

    @zeroVector = Bullet::BtVector3.new(0, 0, 0)
    @moveDir = Ogre::Vector3.new(0, 0, 0)
    @cameraDir = Ogre::Vector3.new(0, 0, 0)
  end

  def clear_action()
    @forward = false
    @backward = false
    @left = false
    @right = false
  end

  def is_move()
    return (@forward || @backward || @left || @right)
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

  #
  # This direction is the forward.
  #
  def move_camera_direction(cameraDir)
    @cameraDir = cameraDir
  end

  def update_target(delta)
    @moveDir.x = 0
    @moveDir.y = 0
    @moveDir.z = 0

    # update target's acceleration
    if (@forward)
      @moveDir += Ogre::Vector3.new(@cameraDir.x, @cameraDir.y, @cameraDir.z)
    end
    if (@backward)
      @moveDir += Ogre::Vector3.new(-@cameraDir.x, -@cameraDir.y, -@cameraDir.z)
    end
    if (@left)
      @moveDir += Ogre::Vector3.new(@cameraDir.z, 0,  -@cameraDir.x)
    end
    if (@right)
      @moveDir += Ogre::Vector3.new(-@cameraDir.z, 0, @cameraDir.x)
    end

    @moveDir.y = 0
    @moveDir.normalise()

    if (@movable)
      newAcc = @moveDir * @acceleration
      @targetObject.set_acceleration(Vector3D::to_bullet(newAcc))
    else
      @targetObject.set_acceleration(@zeroVector)
    end

    # update target's direction
=begin
    ogreDir = -@targetObject.pivotSceneNode.getOrientation().zAxis()
    bulletDir = -@targetObject.getOrientation().zAxis()
    puts "OgreDir: (#{ogreDir.x}, #{ogreDir.y}, #{ogreDir.z})"
    puts "BulletDir: (#{bulletDir.x}, #{bulletDir.y}, #{bulletDir.z})"
=end

    toGoal = Vector3D.to_ogre(-@targetObject.get_orientation().z_axis()).get_rotation_to(@moveDir)
    yawToGoal = toGoal.get_yaw().value_degrees()
    yawAtSpeed = yawToGoal / yawToGoal.abs * delta * @turnSpeed

    if (yawToGoal < 0) 
      yawToGoal = [0, [yawToGoal, yawAtSpeed].max].min

    elsif (yawToGoal > 0) 
      yawToGoal = [0, [yawToGoal, yawAtSpeed].min].max
    end

    @targetObject.yaw(Ogre::Degree.new(yawToGoal).value_radians())
  end
end

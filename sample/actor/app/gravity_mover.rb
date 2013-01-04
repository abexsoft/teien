class GravityMover
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

  def clearAction()
    @forward = false
    @backward = false
    @left = false
    @right = false
  end

  def isMove()
    return (@forward || @backward || @left || @right)
  end

  def moveForward(bool)
    @forward = bool
  end

  def moveBackward(bool)
    @backward = bool
  end

  def moveLeft(bool)
    @left = bool
  end

  def moveRight(bool)
    @right = bool
  end

  #
  # This direction is the forward.
  #
  def moveCameraDirection(cameraDir)
    @cameraDir = cameraDir
  end

  def updateTarget(delta)
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

#    @moveDir.y = 0
    @moveDir.normalise()

    if (@movable)
      newAcc = @moveDir * @acceleration
      @targetObject.setAcceleration(Vector3D::to_bullet(newAcc))
    else
      @targetObject.setAcceleration(@zeroVector)
    end

    toGoal = Vector3D.to_ogre(-@targetObject.getOrientation().zAxis()).getRotationTo(@moveDir)
    yawToGoal = toGoal.getYaw().valueDegrees()
    yawAtSpeed = yawToGoal / yawToGoal.abs * delta * @turnSpeed

    if (yawToGoal < 0) 
      yawToGoal = [0, [yawToGoal, yawAtSpeed].max].min

    elsif (yawToGoal > 0) 
      yawToGoal = [0, [yawToGoal, yawAtSpeed].min].max
    end

    @targetObject.yaw(Ogre::Degree.new(yawToGoal).valueRadians())
  end
end

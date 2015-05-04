require 'matrix'

# deep copy
def deep_copy(object)
  return Marshal.load(Marshal.dump(object))
end

module Teien

#
# 2d vector
#
class Vector2D
  attr_accessor :x
  attr_accessor :y
  def initialize(x = 0.0, y = 0.0)
    set(x, y)
  end

  def set(x, y)
    @x = x
    @y = y
  end

  def ==(o)
    if o.is_a?(Vector2D)
      return @x == o.x && @y == o.y
    else
      return false
    end
  end
end

class Vector3D
  attr_accessor :x
  attr_accessor :y
  attr_accessor :z
  def initialize(x = 0.0, y = 0.0, z = 0.0)
    set(x, y, z)
  end

  def set(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  def to_hash
    {:x => @x, :y => @y, :z => @z}
  end

  def from_hash(hash)
    @x = hash[:x]
    @y = hash[:y]
    @z = hash[:z]
  end

  def copy(vec)
    set(vec.x, vec.y, vec.z)
  end

  def +(pt)
    return Vector3D.new(@x + pt.x, @y + pt.y, @z + pt.z)
  end

  def -(pt)
    return Vector3D.new(@x - pt.x, @y - pt.y, @z - pt.z)
  end

  def -@
    return Vector3D.new(-@x, -@y, -@z)
  end

  def *(f)
    if (f.class == Vector3D)
      return Vector3D.new(@x * f.x, @y * f.y, @z * f.z)
    else
      return Vector3D.new(@x * f, @y * f, @z * f)
    end
  end

  def /(f)
    if (f.class == Vector3D)
      return Vector3D.new(@x / f.x, @y / f.y, @z / f.z)
    else
      return Vector3D.new(@x / f, @y / f, @z / f)
    end
  end

  def ==(pt)
    return (((@x - pt.x).abs <= Float::EPSILON * [@x.abs, pt.x.abs].max) && 
            ((@y - pt.y).abs <= Float::EPSILON * [@y.abs, pt.y.abs].max) && 
            ((@z - pt.z).abs <= Float::EPSILON * [@z.abs, pt.z.abs].max))
  end

  def nearTo(pt)
    return (((@x - pt.x).abs <= 0.000001) && 
            ((@y - pt.y).abs <= 0.000001) && 
            ((@z - pt.z).abs <= 0.000001))
  end

  def dot(pt)
    return (@x * pt.x + @y * pt.y + @z * pt.z)
  end

  def len()
    return Math.sqrt(@x * @x + @y * @y + @z * @z)
  end

  def lenSquared()
    return @x * @x + @y * @y + @z * @z
  end


  def normalize(newLen = 1.0) 
    l = len();
    if (l == 0)
      @x = 0
      @y = 0
      @z = 0
      return false
    else
      l = newLen / l
      @x *= l
      @y *= l
      @z *= l
      return true
    end
  end

  def toString
    return sprintf("(%f, %f, %f)", @x, @y, @z)
  end
end

class Quaternion
  attr_accessor :x
  attr_accessor :y
  attr_accessor :z
  attr_accessor :w
  def initialize(x = 0.0, y = 0.0, z = 0.0, w = 1.0)
    set(x, y, z, w)
  end

  def to_hash
    {:x => @x, :y => @y, :z => @z, :w => @w}
  end

  def from_hash(hash)
    @x = hash[:x]
    @y = hash[:y]
    @z = hash[:z]
    @w = hash[:w]
  end

  def set(x, y, z, w)
    @x = x
    @y = y
    @z = z
    @w = w
  end

  def setYPR(yaw, pitch, roll)
    halfYaw = yaw * 0.5;  
    halfPitch = pitch * 0.5;  
    halfRoll = roll * 0.5;  
    cosYaw = Math::cos(halfYaw);
    sinYaw = Math::sin(halfYaw);
    cosPitch = Math::cos(halfPitch);
    sinPitch = Math::sin(halfPitch);
    cosRoll = Math::cos(halfRoll);
    sinRoll = Math::sin(halfRoll);
                
    @x = cosRoll * sinPitch * cosYaw + sinRoll * cosPitch * sinYaw;
    @y = cosRoll * cosPitch * sinYaw - sinRoll * sinPitch * cosYaw;
    @z = sinRoll * cosPitch * cosYaw - cosRoll * sinPitch * sinYaw;
    @w = cosRoll * cosPitch * cosYaw + sinRoll * sinPitch * sinYaw;

    return self
  end

  def copy(quat)
    set(quat.x, quat.y, quat.z, quat.w)
  end

  def +(pt)
    return Quaternion.new(@x + pt.x, @y + pt.y, @z + pt.z, @w + pt.w);
  end

  def -(pt)
    return Quaternion.new(@x - pt.x, @y - pt.y, @z - pt.z, @w - pt.w);
  end

  def *(f)
      return Quaternion.new(@x * f, @y * f, @z * f, @w * f)
  end

  def dot(pt)
    return (@x * pt.x + @y * pt.y + @z * pt.z + @w * pt.w);
  end

  def len()
    return Math.sqrt(dot(self))
  end
end

class Transform
  attr_accessor :position
  attr_accessor :rotation

  def initialize
    @position = Teien::Vector3D.new
    @rotation = Teien::Quaternion.new
  end

  def to_hash
    {:position => @position.to_hash, :rotation => @rotation.to_hash}
  end

  def from_hash(hash)
    @position.from_hash(hash[:position])
    @rotation.from_hash(hash[:rotation])
  end

end

end # module 

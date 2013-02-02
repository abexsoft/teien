class SkyDome
  attr_accessor :enable
  attr_accessor :materialName
  attr_accessor :curvature
  attr_accessor :tiling
  attr_accessor :distance

  def initialize(enable, materialName, curvature = 10, tiling = 8, distance = 4000)
    @enable = enable
    @materialName = materialName
    @curvature = curvature
    @tiling = tiling
    @distance = distance
  end
end

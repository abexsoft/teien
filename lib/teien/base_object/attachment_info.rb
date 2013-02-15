class AttachmentInfo
  attr_accessor :bone_name 
  attr_accessor :object_name 
  attr_accessor :offset_quaternion
  attr_accessor :offset_position

  def initialize(bone_name, object_name, 
                 offset_quaternion = Quaternion.new(1, 0, 0, 0), 
                 offset_position = Vector3D.new(0, 0, 0))
    @bone_name = bone_name 
    @object_name = object_name 
    @offset_quaternion = offset_quaternion
    @offset_position = offset_position
  end
end

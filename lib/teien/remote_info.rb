
module Teien

class RemoteInfo
  @@total_cnt = 0
  attr_accessor :id
  attr_accessor :ip
  attr_accessor :port
  attr_accessor :connection

  def initialize(con)
    @port, @ip = Socket.unpack_sockaddr_in(con.get_peername)
    @connection = con
    @id = @@total_cnt
    @@total_cnt += 1
  end
end

end

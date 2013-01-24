module Teien

class RemoteInfo
  @@total_cnt = 0
  attr_accessor :id
  attr_accessor :ip
  attr_accessor :port
  attr_accessor :connection

  def initialize(con)
    @ip = nil
    @port = 0
    if con
      @port, @ip = Socket.unpack_sockaddr_in(con.get_peername) if con.get_peername
    else
      @port = 0
      @ip = "dummy ip"
    end
    @connection = con
    @id = @@total_cnt
    @@total_cnt += 1
  end
end

end

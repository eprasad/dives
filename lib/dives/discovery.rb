
module Discovery
  attr_reader :io, :switch, :host, :port
  def initialize (host, port, io, switch)
    @host, @port, @io, @switch = host, port, io, switch
  end
  def advertise
    io.send(switch.get_sockname, 0, host, port)
  end
  def notify_readable
    switch.peer *Socket.unpack_sockaddr_in(io.sysread(9000)).reverse
  end
end


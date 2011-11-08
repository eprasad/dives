
# Another switch.
class Peer
  
  attr_reader :host, :port, :switch
  attr_accessor :pang
  
  def initialize (host, port, switch)
    @host, @port, @switch = host, port, switch
  end
  
  def transmit (frame, vlan)
    switch.send_datagram([vlan.id, frame].pack("Na*"), host, port)
  end
  
  def to_s
    "#{host}:#{port}"
  end
  
end


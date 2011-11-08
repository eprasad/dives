
module Listener
  
  attr_reader :vlan
  
  include EM::P::ObjectProtocol
  
  def unbind
    vlan.taps.delete self
  end
  
  def post_init
    vlan.taps << self
  end
  
  def dump (x)
    x
  end
  
  def load (x)
    x
  end
  
  def serializer
    self
  end
  
  def initialize (vlan)
    @vlan = vlan
    super
  end
  
  def receive_object (frame)
    vlan.transmit(self, frame, false)
  end
  
  def transmit (frame, vlan)
    send_object(frame)
  end
  
  def to_s
    "#{vlan}/unix"
  end
  
end

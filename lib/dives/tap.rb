
module Tap
  
  attr_reader :io, :vlan, :device
  
  def initialize (io, vlan, device)
    @io, @vlan, @device = io, vlan, device
    super
  end
  
  def notify_readable
    vlan.transmit(self, io.sysread(9000), false)
  end
  
  def transmit (frame, vlan)
    @io.syswrite(frame)
  end
  
  def to_s
    @device
  end
  
  def close
    self.detach
    self.notify_readable = false
    self.io.close
    vlan.macs.replace({})
  end
  
end


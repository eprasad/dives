
require 'dives/tap'

# A VLAN. Not a 802.1q VLAN.
class Vlan
  
  attr_reader :id, :switch
  
  def initialize (switch, id)
    @switch, @id = switch, id
    EM.add_periodic_timer(1) do
      age_macs
    end
  end
  
  def execute (line, reply)
    case line
    when /^show macs$/
      macs.each do |mac, (port, time)|
        reply.send_data "%s  %-10s  %is\n" % [mac.bytes.map{|x|"%02x"%x}.join(":"),
                              port,
                              Time.now - time]
      end
    when /^show taps$/
      taps.each do |tap|
        reply.send_data "#{tap}\n"
      end
    when /^no tap (\S+)/
      taps.each do |tap|
        if tap.device == $1
          tap.close
          taps.delete tap
        end
      end
    when /^tap (\S+)$/
      tap $1
    when /^listen (\S+) (\d+)$/
      listen $1, $2.to_i
    else
      reply.send_data "Bad command\n"
    end
  end
  
  def age_macs
    macs.keys.each do |mac|
      macs.delete(mac) if macs[mac][1] < Time.now - 15
    end
  end
  
  def macs
    @macs ||= {}
  end
  
  def taps
    @taps ||= []
  end
  
  def to_s
    "vlan#{id}"
  end
  
  def listen (host, port)
    EM.start_server(host, port, Listener, self, host, port)
  end
  
  def tap (device)
    io = open("/dev/net/tun", "w+")
    ifr = [device, 0x0002 | 0x1000].pack("a16S")
    io.ioctl(0x400454ca, ifr)
    taps << (conn = EM.watch(io, Tap, io, self, device))
    conn.notify_readable = true
  end
  
  def lookup mac
    port, time = macs[mac]
    port
  end
  
  # Switch FRAME from SOURCE to suitable ports on this vlan.
  def transmit (source, frame, local_only)
    d_mac = frame[0...6]
    s_mac = frame[6...12]
    puts "Packet from #{switch}/#{source}/#{s_mac.bytes.map{|p|"%02x"%[p]}.join(":")}"
    if s_mac[0].to_i & 0x1 == 0
      puts "  Learning where #{s_mac.bytes.map{|p|"%02x"%[p]}.join(":")} is"
      macs[s_mac] = [source, Time.now]
    end
    if d = lookup(d_mac)
      puts "  Forwarding to #{d}"
      d.transmit(frame, self) unless d == source
    else
      puts "  Broadcasting"
      taps.each do |socket|
        next if socket == source
        puts "    + #{socket}"
        socket.transmit(frame, self)
      end
      switch.peers.values.each do |socket|
        next if socket == source
        puts "    + #{socket}"
        socket.transmit(frame, self)
      end unless local_only
    end
  end
  
end


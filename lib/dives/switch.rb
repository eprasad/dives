
require 'dives/options'
require 'dives/discovery'
require 'dives/control'
require 'dives/vlan'
require 'dives/listener'
require 'dives/peer'

# An virtual switch.
module Switch
  
  attr_accessor :unix_dir
  
  def initialize (options)
    @options = options
    @unix_dir = @options[:unix_dir]
  end
  
  def post_init
    EM.add_periodic_timer(1) do
      age_peers
    end
    EM.start_unix_domain_server(File.join(unix_dir, "ctl"), Control, self)
    #@options[:rc].each do |rc|
    #  c1 = EM.connect_unix_domain(File.join(unix_dir, "ctl"), Chomper)
    #  open(rc, "r") do |io|
    #    c1.send_data(io.readline) until io.eof?
    #  end
    #end
    watch_adverts(@options[:discovery_address], @options[:discovery_port])
  end
  
  def vlans
    @vlans ||= Hash.new { |h, k| h[k] = Vlan.new(self, k) }
  end
  
  def listen (host, port, vlan_id)
    vlans[vlan_id].listen(host, port)
  end
  
  def tap (device, vlan_id)
    vlans[vlan_id].tap(device)
  end
  
  def peers
    @peers ||= {}
  end
  
  def peer (*args)
    return if args == Socket.unpack_sockaddr_in(get_sockname).reverse
    unless peer = peers[args]
      peer = peers[args] ||= Peer.new(*args, self)
      puts "discovered peer #{peer}"
    end
    peer.pang = Time.now
  end
  
  def receive_data (frame)
    vlan_id, frame = frame.unpack("Na*")
    vlans[vlan_id].transmit(peers[Socket.unpack_sockaddr_in(get_peername).reverse], frame, true)
  end
  
  def to_s
    Socket.unpack_sockaddr_in(get_sockname).reverse.join(":")
  end
  
  def age_peers
    dead_age = Time.now - 5
    peers.keys.each do |addr|
      if peers[addr].pang < dead_age
        puts "timing out peer #{addr.join(":")}"
        peers.delete(addr)
      end
    end
  end
  
  def watch_adverts (host, port)
    host = Socket.unpack_sockaddr_in(Socket.pack_sockaddr_in(0, host))[1]
    io = UDPSocket.new
    ip = IPAddr.new(host).hton + IPAddr.new("0.0.0.0").hton
    io.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, [1].pack("i"))
    io.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip)
    io.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_LOOP, [1].pack("i"));
    io.bind(host, port)
    @dh = EM.watch(io, Discovery, host, port, io, self)
    @dh.notify_readable = true
    EM.add_periodic_timer(1) do
      @dh.advertise
    end
    @dh.advertise
  end
  
end


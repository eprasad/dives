
module Control
  
  include EM::P::LineText2
  
  attr_reader :switch
  
  def initialize (switch)
    @switch = switch
    @reloader = Rack::Reloader.new(proc{}, 0)
    super
  end
  
  module Client
    
    include EM::P::LineText2
    
    def post_init
      @queue = Queue.new
    end
    
    def execute (line)
      send_data(line + "\n")
      @queue.pop
    end
    
    def receive_line (line)
      if line =~ /^OK(.*)$/
        @queue.push $1
      else
        STDOUT.puts line
      end
    end
    
  end
  
  def post_init
    @reloader.call({})
    @focus = [self]
  end
  
  def handle (line)
    if line == "exit"
      @focus.pop if @focus.length > 1
    else
      @focus[-1].execute(line, self)
    end
  end
  
  def execute (line, reply)
    case line
    when /^show vlans$/
      send_data switch.vlans.keys.join("\n")
    when /^vlan (\d+)$/
      @focus.push switch.vlans[$1.to_i]
    when /^show peers$/
      send_data("%-16s %5s %s\n" % ["host", "port", "age"])
      send_data(switch.peers.values.map do |peer|
        "%-16s %5d %d\n" % [peer.host, peer.port, (Time.now - peer.pang).to_i]
      end.join("\n"))
    else
      send_data "Bad command\n"
    end
  end
  
  def receive_line (line)
    @reloader.call({})
    begin
      handle line.gsub(/\s+/, ' ').strip
    rescue => e
      send_data "#{e} occured: #{e.backtrace[0]}\n"
    end
    send_data "OK#{@focus[1..-1].join(":")}\n"
  end
  
end


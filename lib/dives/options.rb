
module Dives
  
  Options = {
    host: "127.0.0.1",
    discovery_address: "239.13.13.13",
    port: 3333,
    discovery_port: 3535,
    rc: [],
    unix_dir: "./"
  }

  # Yeah, this is an option parser.
  OptionParser.new do |op|
    op.banner = "Usage: #{$0} [options] {TAPDEV VLAN}..."
    op.on "-?", "--help", "Show this message" do
      puts op
      exit
    end
    op.on "-c FILE", "Run control file FILE" do |arg|
      Options[:rc] << arg
    end
    op.on "-h ADDRESS", "Unicast address [Default: 127.0.0.1]" do |arg|
      Options[:host] = arg
    end
    op.on "-p PORT", "Unicast port number [Default: 3333]" do |arg|
      Options[:port] = arg.to_i
    end
    op.on "-d PORT", "Discovery port number [Default: 3535]" do |arg|
      Options[:discovery_port] = arg.to_i
    end
    op.on "-m ADDRESS", "Discovery address [Default: 239.13.13.13]" do |arg|
      Options[:discovery_address] = arg
    end
    op.on "-u DIR", "Directory to store UNIX sockets in [Default: ./]" do |arg|
      Options[:unix_dir] = arg
    end
    op.parse!
  end
  
end


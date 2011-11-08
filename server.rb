## DIVES - DIstributed Virtual Ethernet Switch

Thread.abort_on_exception = true

require 'rack/reloader'
require 'eventmachine'
require 'readline'
require 'optparse'
require 'socket'
require 'ipaddr'

$:.unshift "lib"

require 'dives/switch'

unless EM.reactor_running?
  options = Dives::Options
  EM.run do
    s = EM.open_datagram_socket(options[:host], options[:port], Switch, options)
    c = EM.connect_unix_domain(File.join(s.unix_dir, "ctl"), Control::Client)
    Thread.new do
      p = ""
      p = c.execute Readline.readline("#{p}> ") while true
    end
  end
end


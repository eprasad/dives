
# DiVES: Distributed Virtual Ethernet Switch

## Overview

DiVES is a distributed switch in the style of VDE. It is designed particularly
for use with clusters of hosts running Qemu virtual machines, but might
be useful for other purposes.

## How To Use

    ruby server.rb [options]

    -?, --help                       Show this message
    -c FILE                          Run control file FILE
    -h ADDRESS                       Unicast address [Default: 127.0.0.1]
    -p PORT                          Unicast port number [Default: 3333]
    -d PORT                          Discovery port number [Default: 3535]
    -m ADDRESS                       Discovery address [Default: 239.13.13.13]
    -u DIR                           Directory to store UNIX sockets in [Default: ./]

DiVES uses multicast UDP to find other switches it should peer with.

It opens a UNIX socket in a directory specified by the -u option which can
be used for controlling it. It also starts up a control console session on
its stdio.

## Control console

### Switch-level commands

<table>
<tr><th>show peers                       <td>Display a list of discovered peers.
<tr><th>vlan ID                          <td>Enter VLAN configuration.
</table>

### VLAN-level commands

<table>
<tr><th>show macs                        <td>Show MACs seen on this VLAN, and
                                   the interfaces they've been seen on.
  
<tr><th>show taps                        <td>Show attached tap devices.
  
<tr><th>tap DEVNAME                      <td>Attach the tap interface DEVNAME to this
                                   VLAN.
  
<tr><th>no tap DEVNAME                   <td>Detach the tap interface DEVNAME from
                                   this VLAN.

<tr><th>listen HOSTNAME PORT             <td>Listen for Qemu connections on the
                                   specified address.
 
</table>

## Qemu

Start Qemu as e.g.

    qemu -net nic -net socket,connect=HOSTNAME:PORT

The qemu socket-based network protocol sends a 4-byte frame length followed
that many bytes of the frame.

## Peer Protocol

The peer protocol consists of UDP packets containing a 4-byte VLAN id
followed by the original frame data.

The multicast discovery messages are simple strings with the format

    HOSTNAME:PORT


# Zion

# Tofino implementation of Prototype of manual parser creation from multiple packet filter queries

This directory hosts P4 implementation of the manmual parser creation running on the Barefoot Tofino programmable switch.

## Compiling and running P4 code

### terminal 1

* . ./tools/set-sde.bash
* ~/tools/p4_build.sh parser_demo.p4
* ./run_tofino_model.sh -p parser_demo

### terminal 2

* . ./tools/set-sde.bash
* ./run_switchd.sh -p parser_demo

### terminal 3

* . ./tools/set-sde.bash
* ./bf-sde-9.7.0/run_bfshell.sh -b ~/xiaofu/zion/scripts/setup.py

### terminal 4

* python send.py

If all goes well, you will see:

```
.
Sent 1 packets.
.
Sent 1 packets.
```

### terminal 5

* python receive.py

you will see:

```
sniffing on veth2
###[ Ethernet ]###
  dst       = 50:da:00:71:30:02
  src       = d4:f5:ef:59:61:78
  type      = IPv4
###[ IP ]###
     version   = 4L
     ihl       = 5L
     tos       = 0x0
     len       = 35
     id        = 1
     flags     = 
     frag      = 0L
     ttl       = 64
     proto     = udp
     chksum    = 0xb51c
     src       = 2.2.2.2
     dst       = 192.168.1.1
     \options   \

......

```

At the same moment, the terminal will print how the switch process the packetes,just like:
```
:02-08 20:42:33.662752:    :-:-:<0,-,0>:Begin packet processing
:02-08 20:42:33.663047:    :0x1:-:<0,0,0>:========== Ingress Pkt from port 64 (64 bytes)  ==========
:02-08 20:42:33.663091:    :0x1:-:<0,0,0>:Packet :
:02-08 20:42:33.663131:        :0x1:-:<0,0,0>:50 da 00 71 30 02 d4 f5 ef 59 61 78 08 00 45 00 
:02-08 20:42:33.663168:        :0x1:-:<0,0,0>:00 23 00 01 00 00 40 11 b5 1c 02 02 02 02 c0 a8 
:02-08 20:42:33.663203:        :0x1:-:<0,0,0>:01 01 00 35 00 35 00 0f 7c 89 70 61 79 6c 6f 61 
:02-08 20:42:33.663237:        :0x1:-:<0,0,0>:64 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
:02-08 20:42:33.663279:    :0x1:-:<0,0,->:========== Packet to input parser: from port 64 (80 bytes)  ==========
:02-08 20:42:33.663311:    :0x1:-:<0,0,->:Packet :
:02-08 20:42:33.663346:        :0x1:-:<0,0,->:00 40 00 27 80 4c ee 90 00 00 00 00 00 00 00 00 
:02-08 20:42:33.663381:        :0x1:-:<0,0,->:50 da 00 71 30 02 d4 f5 ef 59 61 78 08 00 45 00 
:02-08 20:42:33.663416:        :0x1:-:<0,0,->:00 23 00 01 00 00 40 11 b5 1c 02 02 02 02 c0 a8 
:02-08 20:42:33.663450:        :0x1:-:<0,0,->:01 01 00 35 00 35 00 0f 7c 89 70 61 79 6c 6f 61 
:02-08 20:42:33.663644:    :0x1:-:<0,0,->:Ingress Parser state '$entry_point'
:02-08 20:42:33.663735:    :0x1:-:<0,0,->:Ingress Parser state 'start'
:02-08 20:42:33.663845:        :0x1:-:<0,0,->:Ingress Parser state 'start': extracted       0x01, updating PHV word  65 to value       0x01 I [POV]
:02-08 20:42:33.663991:        :0x1:-:<0,0,->:Ingress Parser state 'start': extracted     0x0800, updating PHV word 326 to value     0x0800 I [hdr.ethernet.ether_type[15:0]]
:02-08 20:42:33.664101:        :0x1:-:<0,0,->:Ingress Parser state 'start': extracted     0xd4f5, updating PHV word 327 to value     0xd4f5 I [hdr.ethernet.dst_mac[47:32]]
:02-08 20:42:33.664212:        :0x1:-:<0,0,->:Ingress Parser state 'start': extracted     0x50da, updating PHV word 328 to value     0x50da I [hdr.ethernet.src_mac[47:32]]
:02-08 20:42:33.664310:        :0x1:-:<0,0,->:Ingress Parser state 'start': extracted 0xef596178, updating PHV word 261 to value 0xef596178 I [hdr.ethernet.dst_mac[31:0]]
:02-08 20:42:33.664400:        :0x1:-:<0,0,->:Ingress Parser state 'start': extracted 0x00713002, updating PHV word 262 to value 0x00713002 I [hdr.ethernet.src_mac[31:0]]
:02-08 20:42:33.664480:    :0x1:-:<0,0,->:Ingress Parser state 'start.$oob_stall_1'
:02-08 20:42:33.664572:    :0x1:-:<0,0,->:Ingress Parser state 'parse_ipv4'
```



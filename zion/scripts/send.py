from scapy.all import *


def main():
    pkt = Ether()/IP(src = "2.2.2.2",dst = "192.168.1.1")/UDP()/"payload"
    sendp(pkt, iface="veth251")

    pkt2 = Ether()/IP(src = "2.2.2.5",dst = "192.168.1.10")/UDP()/"pay123"
    sendp(pkt2, iface="veth251")

if __name__ == '__main__':
    main()
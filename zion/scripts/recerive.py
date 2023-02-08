from scapy.all import *

def main():
    iface = "veth2"
    print("sniffing on %s" % iface)
    sniff(iface = iface, prn = lambda pkt: pkt.show())

if __name__ == '__main__':
    main()
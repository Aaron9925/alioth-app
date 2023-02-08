# insert entries to the ipv4_host and ipv4_lpm
# run with ./run_bfshell.sh -b ./setup.py -i

from ipaddress import ip_address

p4 = bfrt.parser_demo.pipe

table1 = p4.Ingress.ipv4_host
table2 = p4.Ingress.ipv4_lpm



table1.add_with_send(dst_addr=ip_address("192.168.1.1"),port=1)
table1.add_with_send(ip_address("192.168.1.2"),2)
table1.add_with_drop(ip_address("192.168.1.3"))

table2.add_with_send(dst_addr=ip_address("192.168.1.0"),dst_addr_p_length = 24, port = 64)

bfrt.complete_operations()
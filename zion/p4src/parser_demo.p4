#include <core.p4>
#include <tna.p4>

typedef bit<48> mac_addr;
typedef bit<32> ipv4_addr_t;
typedef bit<16> ethernet_type_t;

enum bit<16> ether_type_t {
    TPID       = 0x8100,
    IPV4       = 0x0800
}

enum bit<8>  ip_proto_t {
    TCP   = 6,
    UDP   = 17
}
header ethernet_t{
    mac_addr src_mac;
    mac_addr dst_mac;
    ethernet_type_t ethernet_type;
}

header vlan_tag_t{
    bit<3>        pcp;
    bit<1>        cfi;
    bit<12>       vid;
    ether_type_t  ether_type;
}

header ipv4_t {
    bit<4>       version;
    bit<4>       ihl;
    bit<8>       diffserv;
    bit<16>      total_len;
    bit<16>      identification;
    bit<3>       flags;
    bit<13>      frag_offset;
    bit<8>       ttl;
    ip_proto_t   protocol;
    bit<16>      hdr_checksum;
    ipv4_addr_t  src_addr;
    ipv4_addr_t  dst_addr;
}

header tcp_t {
    bit<16>  src_port;
    bit<16>  dst_port;
    bit<32>  seq_no;
    bit<32>  ack_no;
    bit<4>   data_offset;
    bit<4>   res;
    bit<8>   flags;
    bit<16>  window;
    bit<16>  checksum;
    bit<16>  urgent_ptr;
}

header udp_t {
    bit<16>  src_port;
    bit<16>  dst_port;
    bit<16>  len;
    bit<16>  checksum;
}

//rdma over rocev2
header rocev2_t {
    bit<8>   opcode;
    bit<1>   S;
    bit<1>   M;
    bit<2>   pad;
    bit<4>   TVer;
    bit<16>  partition_key;
    bit<8>   rsvd;
    bit<24>  dst_QP;
    bit<1>   ack;
    bit<7>   rsvd2;
    bit<24>  PSN;
}

struct my_ingress_metadata_t{

}

struct my_ingress_headers_t{
    ethernet_t ethernet;
    vlan_tag_t vlan_tag;
    ipv4_t ipv4;
    tcp_t tcp;
    udp_t udp;
    rocev2_t rocev2;
}

parser IngressParser(packet_in pkt,
    out my_ingress_headers_t hdr,
    out my_ingress_metadata_t my_ingr_md,
    out ingress_intrinsic_metadata_t ingr_intr_md)
{

    state start{
        pkt.extract(ingr_intr_md);
        pkt.advance(PORT_METADATA_SIZE);
        transition meta_init;
    }


    state parse_ethernet{
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type){
            (bit<16>)ether_type_t.TPID &&& 0xEFFF :  parser_vlan_tag;
            (bit<16>)ether_type_t.IPV4            :  parser_ipv4;
            default :  accept;
        }
    }
    state parser_vlan_tag{
        pkt.extract(hdr.vlan_tag);
        transition select(hdr.vlan_tag.ether_type)
        {
            (bit<16>)ether_type_t.IPV4            :  parser_ipv4;
            default :  accept;
        }
    }
    state parser_ipv4{
        pkt.extract(hdr.ipv4);
        transition select(hdr.ipv4.ip_proto_t){
            (bit<8>)ip_proto_t.TCP                :  parse_tcp;
            (bit<8>)ip_proto_t.UDP                :  parse_udp;
        }
    }


    state parse_tcp{
        pkt.extract(hdr.tcp);
        transition accept;
    }
    
    state parse_udp{
        pkt.extract(hdr.udp);
        transition select(hdr.udp.dst_port){
            (bit<16>)4791                         :  parse_rocev2;
            default :  accept;
        }
    }

    state parse_rocev2{
        pkt.extract(hdr.rocev2);
        transition accept;
    }
    

}

control Ingress(inout my_ingress_headers_t hdr,
    inout my_ingress_metadata_t my_ingr_md,
    in ingress_intrinsic_metadata_t ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t        ig_tm_md
)
{
    action drop(){
        ig_dprsr_md.drop_ctl = 1;
    }
    
    action send(PortId_t port){
        ig_tm_md.ucast_egress_port = port;
    }

    table ipv4_host{
        key = { hdr.ipv4.dst_addr : exact; }
        action = {
            send;
            drop;
        }
        size = 1024;
    }

    table ipv4_lpm{
        key = {hdr.ipv4.dst_addr : lpm; }
        action = {
            send;
            drop;
        }

        default_action = send(64);

        size = 1024;
    }

    apply{
        if(hdr.ipv4.isValid()){
            if(!ipv4_host.apply().hit){
                ipv4_lpm.apply();
            }
        }
    }

}

control IngressDeparser(packet_out pkt,
    inout my_ingress_headers_t hdr,
    in my_ingress_metadata_t meta,
    in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md)
{
    Checksum() ipv4_checksum;
    apply {
        pkt.emit(hdr);
    }
}


struct my_egress_headers_t {
}

struct my_egress_metadata_t {
}


parser EgressParser(packet_in      pkt,
    out my_egress_headers_t          hdr,
    out my_egress_metadata_t         meta,
    out egress_intrinsic_metadata_t  eg_intr_md)
{
    state start {
        pkt.extract(eg_intr_md);
        transition accept;
    }
}

control Egress(
    inout my_egress_headers_t                          hdr,
    inout my_egress_metadata_t                         meta,
    in    egress_intrinsic_metadata_t                  eg_intr_md,
    in    egress_intrinsic_metadata_from_parser_t      eg_prsr_md,
    inout egress_intrinsic_metadata_for_deparser_t     eg_dprsr_md,
    inout egress_intrinsic_metadata_for_output_port_t  eg_oport_md)
{
    apply {

    }
}


control EgressDeparser(packet_out pkt,
    inout my_egress_headers_t                       hdr,
    in    my_egress_metadata_t                      meta,
    in    egress_intrinsic_metadata_for_deparser_t  eg_dprsr_md)
{
    apply {
        pkt.emit(hdr);
    }
}

Pipeline(
    IngressParser(),
    Ingress(),
    IngressDeparser(),
    EgressParser(),
    Egress(),
    EgressDeparser()
)pipe;
Switch(pipe) main;
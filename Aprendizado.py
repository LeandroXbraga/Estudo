import socket

from scapy.all import ARP, Ether, srp

def get_hostname(ip):
    try:
        # Obtém o nome do host associado ao endereço IP
        hostname, _, _ = socket.gethostbyaddr(ip)
        return hostname
    except socket.herror:
        # Se não for possível obter o nome do host, retorna None
        return None

def scan(ip, interface="eth0"):
    arp = ARP(pdst=ip)
    ether = Ether(dst="ff:ff:ff:ff:ff:ff")
    packet = ether/arp
    result = srp(packet, timeout=3, iface=interface, inter=0.1)[0]

    devices = []
    for sent, received in result:
        ip_address = received.psrc
        mac_address = received.hwsrc
        hostname = get_hostname(ip_address)
        devices.append({'ip': ip_address, 'mac': mac_address, 'hostname': hostname})

    return devices

devices = scan("192.168.1.0/24")

for device in devices:
    print(f"IP: {device['ip']}\tMAC: {device['mac']}\tHostname: {device['hostname']}")
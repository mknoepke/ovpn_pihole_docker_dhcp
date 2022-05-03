
# create an openvpn environment with docker to network clients from different locations. configure an openvpn to managing ip pool and manage dns resolution for all connected clients

c1 <----(secure)-----> c2
c1 <-> ovpn-server <-> c2

## testrun

### i run my setup.sh script
> ./setup.sh

### finetune the openvpn.conf
swap line
 server *
to
 server-bridge 10.5.0.2 255.255.255.0 10.5.0.100 10.5.0.199

### checked dhcp is running

```
$ docker-compose up dhcpcheck
Starting ovpn_dhcpcheck_1 ... done
Attaching to ovpn_dhcpcheck_1
dhcpcheck_1  | Starting Nmap 7.92 ( https://nmap.org ) at 2022-05-03 09:58 UTC
dhcpcheck_1  | Failed to resolve "nmap".
dhcpcheck_1  | Pre-scan script results:
dhcpcheck_1  | | broadcast-dhcp-discover:
dhcpcheck_1  | |   Response 1 of 1:
dhcpcheck_1  | |     Interface: eth0
dhcpcheck_1  | |     IP Offered: 10.5.0.27
dhcpcheck_1  | |     DHCP Message Type: DHCPOFFER
dhcpcheck_1  | |     Server Identifier: 10.5.0.3
dhcpcheck_1  | |     IP Address Lease Time: 1d00h00m00s
dhcpcheck_1  | |     Renewal Time Value: 12h00m00s
dhcpcheck_1  | |     Rebinding Time Value: 21h00m00s
dhcpcheck_1  | |     Subnet Mask: 255.255.255.0
dhcpcheck_1  | |     Broadcast Address: 10.5.0.255
dhcpcheck_1  | |     Domain Name Server: 10.5.0.3
dhcpcheck_1  | |     Domain Name: lan
dhcpcheck_1  | |_    Router: 10.5.0.3
dhcpcheck_1  | WARNING: No targets were specified, so 0 hosts scanned.
dhcpcheck_1  | Nmap done: 0 IP addresses (0 hosts up) scanned in 10.41 seconds
ovpn_dhcpcheck_1 exited with code 0
```
### start server
```
$ docker-compose exec server bash -c "/etc/openvpn/bridge-start; ovpn_run;/etc/openvpn/bridge-stop"
```

### and logged in via vpn twice and checked ips on client and on server
```
$ ip add s |grep "tun\|tap\|wlp2s0"|grep -v "link" -A 5;echo; echo; docker-compose exec server bash -c "ip addr s|grep -v "link" "
6576: wlp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 192.168.178.28/24 brd 192.168.178.255 scope global dynamic noprefixroute wlp2s0
18373: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 100
    inet 10.5.0.100/24 brd 10.5.0.255 scope global tap0
18374: tap1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 100
    inet 10.5.0.101/24 brd 10.5.0.255 scope global tap1


1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
5: tap0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc fq_codel master br0 state UP group default qlen 100
6: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.5.0.2/24 brd 10.5.0.255 scope global br0
       valid_lft forever preferred_lft forever
18365: eth0@if18366: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc noqueue master br0 state UP group default
```

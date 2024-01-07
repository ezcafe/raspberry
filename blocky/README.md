# blocky

Open port 19964 in firewall

## Setup DSN for router Viettel ZTE F670Y

- Go to router ip address
- Tab `Local Network` -> Click menu `Lan`
- Click `IPv4` -> Click `DHCP Server`
- Set `ISP DNS` -> `Off`
- Enter ip address of your PiHole server
- Do the same for `IPv6`, click `IPv6` -> Click `DHCPv6 Server`
- Set `ISP DNS` -> `Off`
- Apply and Reboot

Note:
- To get IPv4: `hostname -I | awk '{print $1}'`
- To get IPv6: `ip -brief -6 address`
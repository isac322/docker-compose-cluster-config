#!/usr/bin/env sh

iptables -N TCP
iptables -N UDP
iptables -N IN_SSH
iptables -N LOG_AND_DROP

iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT

iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -j IN_SSH
iptables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP

iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable

# Web server
iptables -A TCP -p tcp --dport 80 -j ACCEPT
iptables -A TCP -p tcp --dport 443 -j ACCEPT

# SSH Rate Limit
iptables -A IN_SSH -m recent --name sshbf --rttl --rcheck --hitcount 3 --seconds 10 -j LOG_AND_DROP
iptables -A IN_SSH -m recent --name sshbf --rttl --rcheck --hitcount 4 --seconds 1800 -j LOG_AND_DROP
iptables -A IN_SSH -m recent --name sshbf --set -j ACCEPT
iptables -A LOG_AND_DROP -j LOG --log-prefix "iptables deny: " --log-level 7
iptables -A LOG_AND_DROP -j DROP

iptables -P INPUT DROP

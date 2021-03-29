#!/usr/bin/env sh

ip6tables -N TCP
ip6tables -N UDP
ip6tables -N IN_SSH
ip6tables -N LOG_AND_DROP

ip6tables -t raw -A PREROUTING -m rpfilter -j ACCEPT
ip6tables -t raw -A PREROUTING -j DROP

ip6tables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A INPUT -m conntrack --ctstate INVALID -j DROP
ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp -j ACCEPT

ip6tables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -j IN_SSH
ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
ip6tables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j TCP

ip6tables -A INPUT -p udp -j REJECT --reject-with icmp6-adm-prohibited
ip6tables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
ip6tables -A INPUT -j REJECT --reject-with icmp6-adm-prohibited
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type 128 -m conntrack --ctstate NEW -j ACCEPT

# Web server
ip6tables -A TCP -p tcp --dport 80 -j ACCEPT
ip6tables -A TCP -p tcp --dport 443 -j ACCEPT

# SSH Rate Limit
ip6tables -A IN_SSH -m recent --name sshbf --rttl --rcheck --hitcount 3 --seconds 10 -j LOG_AND_DROP
ip6tables -A IN_SSH -m recent --name sshbf --rttl --rcheck --hitcount 4 --seconds 1800 -j LOG_AND_DROP
ip6tables -A IN_SSH -m recent --name sshbf --set -j ACCEPT
ip6tables -A LOG_AND_DROP -j LOG --log-prefix "ip6tables deny: " --log-level 7
ip6tables -A LOG_AND_DROP -j DROP

ip6tables -P INPUT DROP

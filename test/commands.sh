#!/bin/sh

set -uex
rundir=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)")

ip_cmd="$rundir"/../src/ip.py
bridge_cmd="$rundir"/../src/bridge.py
ip_prefix=192.0.2
ip_dest=$ip_prefix.99/32
ip_via=$ip_prefix.98

# basics

$ip_cmd -V
$bridge_cmd -V

$ip_cmd --V
$bridge_cmd --V

$ip_cmd -color=never -V
$bridge_cmd -color=never -V

! $ip_cmd help
! $bridge_cmd help

$ip_cmd help 2>&1 >/dev/null | grep "Usage: ip "
$bridge_cmd help 2>&1 >/dev/null | grep "Usage: bridge "

! $ip_cmd asdf sh
! $bridge_cmd asdf sh

! $ip_cmd -M route sh
! $bridge_cmd -N link sh

# route

! $ip_cmd route help

$ip_cmd route help 2>&1 >/dev/null | grep "Usage: ip route"

$ip_cmd route show

$ip_cmd -j route show | tee | perl -MJSON -e 'decode_json(<STDIN>)'

$ip_cmd -4 route show

$ip_cmd -4 -j route show | perl -MJSON -e 'decode_json(<STDIN>)'

$ip_cmd -4 -j -p route show | tee | grep '"dev": "lo0"'

$ip_cmd -6 route show

$ip_cmd -6 -j route show | tee | perl -MJSON -e 'decode_json(<STDIN>)'

$ip_cmd -j -p -6 route show | grep "fe80::/64"

$ip_cmd ro sho

$ip_cmd r s

! $ip_cmd r asdf

## add/delete

$ip_cmd route add $ip_dest via $ip_via
netstat -anr | grep "$ip_dest" | grep "$ip_via"

$ip_cmd route delete $ip_dest via $ip_via
! netstat -anr | grep "$ip_dest"

$ip_cmd ro add $ip_dest via $ip_via
netstat -anr | grep "$ip_dest" | grep "$ip_via"

$ip_cmd rou de $ip_dest via $ip_via
! netstat -anr | grep "$ip_dest"


## add/show/delete blackhole

$ip_cmd route add blackhole $ip_dest
netstat -anr | grep "$ip_dest" | grep "B"

$ip_cmd ro sh | grep -E "^blackhole $ip_dest"

$ip_cmd route delete blackhole $ip_dest
! netstat -anr | grep "$ip_dest"

# address

$ip_cmd addr help 2>&1 >/dev/null | grep "Usage: ip addr"

$ip_cmd address show

$ip_cmd -j addr show | tee | perl -MJSON -e 'decode_json(<STDIN>)'

$ip_cmd -4 addr show

$ip_cmd -4 -j addr show | tee | perl -MJSON -e 'decode_json(<STDIN>)'

$ip_cmd -4 -j -p addr show dev lo0 | grep '"local": "127.0.0.1"'

$ip_cmd -6 addr show

$ip_cmd -6 -j addr show | tee | perl -MJSON -e 'decode_json(<STDIN>)'

$ip_cmd -j -p -6 addr show dev lo0 | grep '"local": "::1"'

$ip_cmd ad sho

$ip_cmd a s

! $ip_cmd addr asdf

## brief format tests

# Test basic -br addr show
$ip_cmd -br addr show | grep -E "^lo[0-9]* +[A-Z]+ +"

# Test -br a shorthand
$ip_cmd -br a | grep -E "^lo[0-9]* +[A-Z]+ +"

# Test -br with specific device
$ip_cmd -br addr show dev lo0 | grep -E "^lo0 +[A-Z]+ +"

# Test -br with -4 (IPv4 only)
$ip_cmd -4 -br addr show | grep -E "^lo[0-9]* +[A-Z]+ +" | grep "127.0.0.1"

# Test -br with -6 (IPv6 only)
$ip_cmd -6 -br addr show | grep -E "^lo[0-9]* +[A-Z]+ +" | grep "::1"

# Test -br with -j (JSON output should override brief)
$ip_cmd -br -j addr show | perl -MJSON -e 'decode_json(<STDIN>)'

# Test order: -br before command
$ip_cmd -br addr show | grep -E "^lo[0-9]* +[A-Z]+ +"

# Test order: -br after command (should also work)
$ip_cmd addr -br show | grep -E "^lo[0-9]* +[A-Z]+ +"


# link

$ip_cmd link help 2>&1 >/dev/null | grep "Usage: ip link"

$ip_cmd lin hel 2>&1 >/dev/null | grep "Usage: ip link"

$ip_cmd link show | grep mtu

$ip_cmd -j link show | tee | perl -MJSON -e 'decode_json(<STDIN>)'

$ip_cmd -j -p link show dev lo0 | grep '"link_type": "loopback"'

$ip_cmd li sho | grep mtu

$ip_cmd li ls | grep mtu

$ip_cmd lin lst | grep mtu

$ip_cmd l s | grep mtu

! $ip_cmd link asdf

## link brief format tests

# Test basic -br link show
$ip_cmd -br link show | grep -E "^lo[0-9]* +[A-Z]+ +"

# Test -br l shorthand
$ip_cmd -br l | grep -E "^lo[0-9]* +[A-Z]+ +"

# Test -br with specific device
$ip_cmd -br link show lo0 | grep -E "^lo0 +[A-Z]+ +"

# Test -br with -j (JSON output should override brief)
$ip_cmd -br -j link show | perl -MJSON -e 'decode_json(<STDIN>)'

# neigh

$ip_cmd nei help 2>&1 >/dev/null | grep "Usage: ip neighbour"

$ip_cmd nei show

$ip_cmd -j neigh show | tee | perl -MJSON -e 'decode_json(<STDIN>)'

$ip_cmd -j -p neigh show dev lo0 | grep '"dev": "lo0"'

! $ip_cmd neigh asdf

# bridge

! $bridge_cmd help

! $bridge_cmd link help 2>&1 >/dev/null | grep "Usage: bridge link"

$bridge_cmd link show

echo "Tests passed!!"

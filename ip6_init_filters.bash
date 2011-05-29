#!/bin/bash
#
# Configures noop ip6tables rules and munin-node symlinks for all active
# IPv6 addresses.
#
# Ryan Tucker <rtucker@gmail.com>, 2011/05/29
#

MUNIN_PLUGIN_DIR="/etc/munin/plugins"
MUNIN_IP6_LOCATION="${0%/*}/ip6_"  # default: current dir

ADDRESSES=`ip -6 addr list | grep global | awk '{print $2}' | cut -d'/' -f1`
DIDSOMETHING=""

for addr in "${ADDRESSES}"
do
    [ -z "$DEBUG" ] || echo "$0: found address $addr"
    if [ -z "`ip6tables -L INPUT -v -n -x | grep -m1 $addr`" ]
    then
        [ -z "$DEBUG" ] || echo "$0: adding input rule for $addr"
        ip6tables -A INPUT -d $addr
    fi
    if [ -z "`ip6tables -L OUTPUT -v -n -x | grep -m1 $addr`" ]
    then
        [ -z "$DEBUG" ] || echo "$0: adding output rule for $addr"
        ip6tables -A OUTPUT -s $addr
    fi
    filename="${MUNIN_PLUGIN_DIR}/ip6_`echo $addr | sed 's/:/_/g'`"
    if [ ! -x "${filename}" ]
    then
        [ -z "$DEBUG" ] || echo "$0: linking $MUNIN_IP6_LOCATION -> $filename"
        ln -s "$MUNIN_IP6_LOCATION" "$filename"
        DIDSOMETHING="yup"
    fi
done

[ -z "${DIDSOMETHING}" ] || service munin-node restart

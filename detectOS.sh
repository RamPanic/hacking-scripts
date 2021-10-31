#!/bin/bash

HOST=$1

ttl=$(ping -c 1 $HOST | egrep -o "ttl=[0-9]+" | cut -d "=" -f2)

case $ttl in
	63 | 64)  echo "*nix (Linux/Unix) System";;
	32 | 128) echo "Windows System";;
	254)      echo "Solaris System";;
	*)        echo "Unknown System";;
esac

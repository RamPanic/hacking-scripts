#!/bin/bash

function regexIsValid() {

	echo $1 | egrep $2

	return $?

}

function scanPort() {

	timeout 1 bash -c "</dev/tcp/$1/$2" 2>/dev/null

	return $?

}

function printState() {

	case $1 in
		0) echo "Port $2 -> Open";;
		1) echo "Port $2 -> Closed";;
		*) echo "Port $2 -> Filtered or unknown";;
	esac

}

# Constantes

declare -r HOST=$1
declare -r STRING_PORTS=$2
declare -r IP_REGEX="\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}\b"
declare -r STR_PORTS_REGEX="^((([0-9]+)-?){1,2},?)+$"

# Cuando apreto CTRL+C, se envia una señal para detener el programa
trap "exit" SIGINT

# Lógica principal

if [ ! $(regexIsValid $HOST $IP_REGEX) ]; then
	echo "IP Address invalid"
	exit
fi

if [ ! $(regexIsValid $STRING_PORTS $STR_PORTS_REGEX) ]; then
	echo "Ports Format: xx-xxxx,x,xxx,xx,xxx-xxxx"
	exit
fi

port_ranges=()

IFS=',' read -ra port_ranges <<< $STRING_PORTS

for range in ${port_ranges[@]}; do

	ports=()

	IFS='-' read -ra ports <<< $range

	if [ ${#ports[@]} -eq 2 ]; then
		for PORT in $(seq ${ports[0]} ${ports[1]}); do
			scanPort $HOST $PORT
			printState $? $PORT
		done
	else
		scanPort $HOST ${ports[0]}
		printState $? ${ports[0]}
	fi

done

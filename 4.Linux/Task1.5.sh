#!/bin/bash
param=1
while [ -n "$1" ]
do
echo "Parameter $param = $1"
param=$(( $param + 1 ))
shift
done

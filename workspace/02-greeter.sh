#!/usr/bin/env bash

set -euo pipefail


read -r -p "Who are you?" name
if [ -n "$name" ];then
	echo "Hello $name !"
    else
	echo "Your name can not be empty!"
	exit 1
	
fi

read -r -p "What is your role?" role
if [ -n "$role" ]; then
	echo "$name is a professional $role !"
   else
        echo "You should go and find a fucking job!"
	exit 1
fi



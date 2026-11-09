#!/usr/bin/env bash

set -euo pipefail

if [[ $1 == "--help" || $1 == "-h" ]];then
    printf "Usage: %s <num1> <operator> <num2>\n" "$0"
    printf "Operators: + - * /\n"
    exit 0
fi


if [[ $# == 0 || $# > 3 ]];then
    printf 'Error: expected 3 arguments!\n' "$0" >&2
    exit 2
fi

num1=$1
operator=$2
num2=$3



case "$operator" in
    +)
          result=$((num1 + num2))
    ;;
    
    -)
        result=$((num1 - num2))
    ;;
    /)
    if [ "$num2" -eq 0 ]; then
      printf "Error: division by zero\n" >&2
      exit 1
    fi
    result=$((num1 / num2))
    ;;
    "*")
        result=$((num1 * num2))
    ;;
     *)
    printf "Error: invalid operator '%s'\n" "$op" >&2
    exit 1
    ;;
esac

printf "Result: %s\n" "$result"

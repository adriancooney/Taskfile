#!/usr/bin/env bash
PATH=./node_modules/.bin:$PATH

edit() {
    $EDITOR "$0"
}

help() {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | grep -v "_" | cat -n
}

# Load parent .Taskfile files
IFS='/' read -ra dirs <<< "$(pwd)"
dir=''
for i in "${dirs[@]}"
do
    dir="${dir}/${i}"
    f="${dir}/.Taskfile"
    if [ -f $f ]; then
      echo "Using: $f"; source "$f"
    fi
done
echo

TIMEFORMAT="Task completed in %3lR"
time ${@:-help}
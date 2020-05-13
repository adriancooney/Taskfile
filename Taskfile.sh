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

TIMEFORMAT="Task completed in %3lR"
time ${@:-help}
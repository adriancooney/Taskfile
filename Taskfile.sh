#!/bin/bash
PATH=./node_modules/.bin:$PATH

function install {
    echo "install task not implemented"
}

function build {
    echo "build task not implemented"
}

function start {
    echo "start task not implemented"
}

function default {
    start
}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | cat -n
}

TIMEFORMAT="Task completed in %3lR"
time ${@:-default}

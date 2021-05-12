#!/usr/bin/env bash
PATH=./node_modules/.bin:$PATH

edit() {
    # Edit existing .Taskfile or this script.
    FILE=".Taskfile"
    if [ ! -f "$FILE" ]; then
        FILE="$0"
    fi
    echo "Editing $FILE..."
    $EDITOR "$FILE"
}

help() {
    # List all tasks
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | grep -v "_" | cat -n
}

_main() {
    # Load parent .Taskfile files
    IFS='/' read -ra dirs <<< "$(pwd)"
    dir=''
    for i in "${dirs[@]}"
    do
        [ -z "$i" ] && continue
        dir="${dir}/${i}"   
        f="${dir}/.Taskfile"
        if [ -f $f ]; then
          echo "Using: $f"; source "$f"
        fi
    done
    echo

    ${@:-help}    
}
_main $@

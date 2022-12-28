#/bin/bash

_task_completions() {
    words="$(task help | cut -f 1 | grep -P '\w+')"
    COMPREPLY=($(compgen -W "$words" "${COMP_WORDS[1]}"))
}

# Support both `run` and `task` aliases
complete -F _task_completions run
complete -F _task_completions task

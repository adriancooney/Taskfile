#!/usr/bin/env python3
from pathlib import Path


def default():
    task_help()


def task_help():
    """Print documentation of every task"""
    tasks = {name: obj for name, obj in globals().items() if name.startswith("task_")}
    maxwidth = max(len(n) - len("task_") for n in tasks)
    formatter = textwrap.TextWrapper(width=80-maxwidth, subsequent_indent=" " * maxwidth + "\t")
    for name, obj in tasks.items():
        trimmed = name[5:]
        print(trimmed + " "*(maxwidth - len(trimmed)),
              formatter.fill(inspect.getdoc(obj) or ''), sep="\t")


if __name__ == "__main__":
    if len(argv) == 1:
        default()
        exit(0)
    command = "task_" + argv[1]
    if command not in globals():
        print("Command not defined", file=stderr)
        exit(1)
    function = globals()[command]
    function(*argv[2:])

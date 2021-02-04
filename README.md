# Taskfile

This is a fork of Taskfile, optimised as a task runner. See https://github.com/adriancooney/Taskfile for the original project.

This repository contains the runner `Taskfile.sh` for getting started in your own projects. It runs task files, a bash (or zsh etc.) script that contains functions that can be called via the runner. These must be called `.Taskfile`. The runner detects any task files in the current, parent, grandparent etc directory  of the directory you're in.

The `Taskfile.sh` in this repository, when added to a directory in your PATH, contains the runner and help function which lists all the detected tasks.

An example `.Taskfile` could look like this:

```sh
sw() {
  # git fuzzy branch switcher.
  git switch $(git branch | grep $1 | head -n1)
}
```

And to run a task:


    $ t sw CSW-22
    Using: //Users/sander/.Taskfile
    Using: //Users/sander/dev/.Taskfile
     
    Switched to branch 'feature/CSW-22-automatic-language-redirection'
    Your branch is up to date with 'origin/feature/CSW-22-automatic-language-redirection'.
    Task completed in 0m0.043s


## Install
To "install", git clone this repo and add a symlink to `Taskfile.sh` to you a directory in your path, such as `~/bin/t`. Run `chmod +x t` to make the runner executable. Klaar is kees!

## Usage

Open your directory and create a new `.Taskfile`. Edit it with your favourite editor and add your tasks.

To view available tasks, use `t` (which calls the `help` task):

    $ t
    Using: //Users/sander/.Taskfile
    Using: //Users/sander/dev/.Taskfile
     
    /Users/sander/bin/Taskfile.sh <task> <args>
    Tasks:
         1  edit
         2  help
         3  sw
    Task completed in 0m0.004s

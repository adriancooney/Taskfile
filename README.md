# Taskfile

This is a fork of Taskfile, optimised as a task runner. See https://github.com/adriancooney/Taskfile for the original project.

This repository contains the default `Taskfile.sh` for getting started in your own projects. It runs task files, a bash (or zsh etc.) script that follows a specific format. It's called `.Taskfile`, sits in the current or parent directory hierarchy of your project (alongside your package.json) and contains functions that perform tasks.

The `Taskfile.sh` in this repository, when added to a directory in your PATH, will include the .Taskfiles and allow you to run them.

An example `.Taskfile` could look like this:

```sh
# git switch using part of the branch name.
sw() {
    git switch $(git branch | grep $1 | head -n1)
}

# flush macos dns cache
flush-dnscache() {
    sudo launchctl stop /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
    sudo launchctl start /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
}
```

And to run a task:


    $ run sw CSW-22
    Using: //Users/sander/.Taskfile
    Using: //Users/sander/dev/.Taskfile
     
    Switched to branch 'feature/CSW-22-automatic-language-redirection'
    Your branch is up to date with 'origin/feature/CSW-22-automatic-language-redirection'.
    Task completed in 0m0.043s


## Install
To "install", git clone this repo and add a symlink to `Taskfile.sh` to you a directory in your path, such as `~/bin`. Add an alias to your .bashrc to shorthen it to something like `run`:

```sh
    alias run=Taskfile.sh
```

## Usage

Open your directory and create a new `.Taskfile`. Edit it with your favourite editor and add your tasks.

To run tasks, use `run` (which calls `help`:

    $ run
    Using: //Users/sander/.Taskfile
    Using: //Users/sander/dev/.Taskfile
     
    /Users/sander/bin/Taskfile.sh <task> <args>
    Tasks:
         1  edit
         2  flush-dnscache
         3  help
         4  sw
    Task completed in 0m0.004s



The Taskfile format is something I’d love to see become more widespread and it’d be awesome if we could all come together on a standard of sorts. Things like simple syntax highlighting extensions or best practices guide would be awesome to formalise.

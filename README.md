# Taskfile
This repository contains the default Taskfile template for getting started in your own projects. A Taskfile is a bash (or zsh etc.) script that follows a specific format. It's called `Taskfile`, sits in the root of your project (alongside your package.json) and contains the tasks to build your project.

```sh
#!/bin/bash
PATH=./node_modules/.bin:$PATH

function install {
    : "Install dependencies"
    npm install
}

function build {
    : "Build the project"
    webpack
}

function start {
    : "Start a local server"
    build # Call task dependency
    python -m SimpleHTTPServer 9000
}

function test {
    : "Run test suite"
    mocha test/**/*.js
}

function default {
    : "Run a default task"
    # Default task to execute
    start
}

function help {
    : "Auto-generate list of tasks, including documentation in the form of these noop statements"
    : "They can span multiple lines if needed"
    compgen -A function | while read -r name ; do
		paste <(printf '%s' "$name") <(type "$name" | sed -nEe 's/^[[:space:]]*: ?"(.*)";/\1/p')
	done
}

TIMEFORMAT="Task completed in %3lR"
time ${@:-default}
```

And to run a task:

    $ run build
    Hash: 31b6167c7c8f2920e0d2
    Version: webpack 2.1.0-beta.25
    Time: 4664ms
       Asset     Size  Chunks             Chunk Names
    index.js  1.96 MB       0  [emitted]  index
        + 353 hidden modules
    Task completed in 0m5.008s

## Install
To "install", add the following to your `.bashrc` or `.zshrc` (or `.whateverrc`):

    # Quick start with the default Taskfile template
    alias run-init="curl -so Taskfile https://raw.githubusercontent.com/adriancooney/Taskfile/master/Taskfile.template && chmod +x Taskfile"

    # Run your tasks like: run <task>
    alias run=./Taskfile

## Usage
Open your directory and run `run-init` to add the default Taskfile template to your project directory:

    $ cd my-project
    $ run-init

Open the `Taskfile` and add your tasks. To run tasks, use `run`:

    $ run help
    build   Build the project
    default Run a default task
    help    Auto-generate list of tasks, including documentation in the form of these noop statements
    install Install dependencies
    start   Start the server
    Task completed in 0m0.017s

## Techniques
### Arguments
Let’s pass some arguments to a task. Arguments are accessible to the task via the `$1, $2, $n..` variables. Let’s allow us to specify the port of the HTTP server:

```sh
#!/bin/bash

function serve {
  python -m SimpleHTTPServer $1
}

"$@"
```

And if we run the `serve` task with a new port:

    $ ./Taskfile serve 9090
    Serving HTTP on 0.0.0.0 port 9090 ...

### Using npm Packages
One of the most powerful things about npm run-scripts (who am I kidding, it’s definitely the most powerful thing) is the ability to use the CLI interfaces for many of the popular packages on npm such as *babel* or *webpack.* The way npm achieves this is by extending the search `PATH` for binaries to include `./node_modules/.bin`. We can do this to very easily too by extending the `PATH` at the top of our Taskfile to include this directory. This will enable us to use our favourite binaries just like we would in an npm run-script:

```sh
#!/bin/bash
PATH=./node_modules/.bin:$PATH

function serve {
  python -m SimpleHTTPServer $1
}

function build {
  webpack src/index.js --output-path build/
}

function lint {
  eslint src
}

function test {
  mocha src/**/*.js
}

"$@"
```

### Task Dependencies
Sometimes tasks depend on other tasks to be completed before they can start. To add another task as a dependency, simply call the task's function at the top of the dependant task's function.

```sh
#!/bin/bash
PATH=./node_modules/.bin:$PATH

function clean {
  rm -r build dist
}

function build {
  webpack src/index.js --output-path build/
}

function minify {
  uglify build/*.js dist/
}

function deploy {
  clean && build && minify
  scp dist/index.js sergey@google.com:/top-secret/index.js
}

"$@"
```

### Parallelisation
To run tasks in parallel, you can us Bash’s `&` operator in conjunction with `wait`. The following will build the two tasks at the same time and wait until they’re completed before exiting.

```sh
#!/bin/bash
PATH=./node_modules/.bin:$PATH

function build {
    echo "beep $1 boop"
    sleep 1
    echo "built $1"
}

function build-all {
    build web & build mobile &
    wait
}

"$@"
```

And execute the `build-all` task:

    $ run build-all
    beep web boop
    beep mobile boop
    built web
    built mobile

### Default task
To make a task the default task called when no arguments are passed, we can use bash’s default variable substitution `${VARNAME:-<default value>}` to return `default` if `$@` is empty.

```sh
#!/bin/bash
PATH=./node_modules/.bin:$PATH

function build {
    echo "beep boop built"
}

function default {
    build
}

"${@:-default}"
```

Now when we run `./Taskfile`, the `default` function is called.


### Runtime Statistics
To add some nice runtime statistics like Gulp so you can keep an eye on build times, we use the built in `time` and pass if a formatter.

```sh
#!/bin/bash
PATH=./node_modules/.bin:$PATH

function build {
    echo "beep boop built"
    sleep 1
}

function default {
    build
}

TIMEFORMAT="Task completed in %3lR"
time ${@:-default}
```

And if we execute the `build` task:

    $ ./Taskfile build
    beep boop built
    Task completed in 0m1.008s

### Help
The final addition I recommend adding to your base Taskfile is the task which emulates, in a much more basic fashion, (with no arguments). It prints out usage and the available tasks in the Taskfile to show us what tasks we have available to ourself.

The `compgen -A function` is a [bash builtin](https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion-Builtins.html) that will list the functions in our Taskfile (i.e. tasks). Combine this with `type` to print the function body and `sed` to select the documentation lines and a `paste` to print them together. This is what it looks like when we run the task:

    $ ./Taskfile help
    build   Build the project
    default Run a default task
    help    Auto-generate list of tasks, including documentation in the form of these noop statements
    install Install dependencies
    start   Start the server
    Task completed in 0m0.017s

### `task:` namespace
If you find you need to breakout some code into reusable functions that aren't tasks by themselves and don't want them cluttering your `help` output, you can introduce a namespace to your task functions. Bash is pretty lenient with it's function names so you could, for example, prefix a task function with  `task:`. Just remember to use that namespace when you're calling other tasks and in your `task:$@` entrypoint!

```sh
#!/bin/bash
PATH=./node_modules/.bin

function task:build-web {
    : "Build for web use"
    build-target web
}

function task:build-desktop {
    : "Build for desktop use"
    build-target desktop
}

function build-target {
    BUILD_TARGET=$1 webpack --production
}

function task:default {
    : "Run a default task"
    task:help
}

function task:help {
    : "Auto-generate list of tasks, including documentation in the form of these noop statements"
	compgen -A function | while read -r name ; do
		if [[ $name =~ ^task: ]] ; then
			paste <(printf '%s' "${name#task:}") <(type "$name" | sed -nEe 's/^[[:space:]]*: ?"(.*)";/\1/p')
		fi
	done
}

TIMEFORMAT="Task completed in %3lR"
time "task:${@:-default}"
```

### Executing tasks
So typing out `./Taskfile` every time you want to run a task is a little lousy.  just flows through the keyboard so naturally that I wanted something better. The solution for less keystrokes was dead simple: add an alias for `run` (or `task`, whatever you fancy) and stick it in your *.zshrc.* Now, it now looks the part.

    $ alias run=./Taskfile
    $ run build
    beep boop built
    Task completed in 0m1.008s

### Quickstart
Alongside my `run` alias, I also added a `run-init` to my *.zshrc* to quickly get started with a new Taskfile in a project. It downloads a [small Taskfile template](http://github.com/adriancooney/Taskfile) to the current directory and makes it executable:

    $ alias run-init="curl -so Taskfile https://raw.githubusercontent.com/adriancooney/Taskfile/master/Taskfile.template && chmod +x Taskfile"

    $ run-init
    $ run build
    beep boop built
    Task completed in 0m1.008s

### Enable tab-completion
Tab-completion is an extremely useful tool, especially when you're not entirely sure which tasks you have written in your current taskfile. To add completion behavior, download the [completion script found in this repo](https://raw.githubusercontent.com/adriancooney/Taskfile/master/task-completion.bash) and place it in `~/.local/share/bash-completion/completions`. You may have to create that directory.

### Importing from npm
If you've the incredible [jq](https://stedolan.github.io/jq/manual/) installed (you should, it's so useful), here's a handy oneliner to import your scripts from your package.json into a fresh Taskfile. Copy and paste this into your terminal with your package.json in the working directory:

```sh
run-init && (head -n 3 Taskfile && jq -r '.scripts | to_entries[] | "function \(.["key"]) {\n    \(.["value"])\n}\n"' package.json | sed -E 's/npm run ([a-z\:A-Z]+)/\1/g' && tail -n 8 Taskfile) > Taskfile.sh && mv Taskfile.sh Taskfile && chmod +x Taskfile
```

And the importer explained:

```sh
$ run-init && \ # Download a fresh Taskfile template
    (
        head -n 3 Taskfile && \ # Take the Taskfile template header
        # Extract the scripts using JQ and create bash task functions
        jq -r '.scripts | to_entries[] | "function \(.["key"]) {\n    \(.["value"])\n}\n"' package.json \
            | sed -E 's/npm run ([a-z\:A-Z]+)/\1/g' \ # Replace any `npm run <task>` with the task name
        && tail -n 8 Taskfile # Grab the Taskfile template footer
    ) \ # Combine header, body and footer
    > Taskfile.sh && mv Taskfile.sh Taskfile && chmod +x Taskfile # Pipe out to Taskfile
```

To fix up your `npm run-scripts` to use the Taskfile, you can also use JQ to do this automatically for you:

```sh
jq '.scripts = (.scripts | to_entries | map(.value = "./Taskfile \(.key)") | from_entries)' package.json > package.json.2 && mv package.json.2 package.json
```

### Free Features
* Conditions and loops. Bash and friends have support for conditions and loops so you can error if parameters aren’t passed or if your build fails.
* Streaming and piping. Don’t forget, we’re in a shell and you can use all your favourite redirections and piping techniques.
* All your standard tools like `rm` and `mkdir`.
* Globbing. Shells like zsh can expand globs like `**/*.js` for you automatically to pass to your tools.
* Environment variables like `NODE_ENV` are easily accessible in your Taskfiles.

#### Considerations

When writing my Taskfile, these are some considerations I found useful:

* You should try to use tools that you know users will have installed and working on their system. I’m not saying you have to be POSIX.1 compliant but be weary of using tools that aren’t standard (or difficult to install).
* Keep it pretty. The reason for the Taskfile format is to keep your tasks organised and readable.
* Don’t completely ditch the `package.json`. You should proxy the scripts to the Taskfile by calling the Taskfile directory in your package.json like `"test": "./Taskfile test"`. You can still pass arguments to your scripts with the `--` special argument and `npm run build -- --production` if necessary.

#### Caveats
The only caveat with the Taskfile format is we forgo compatibility with Windows which sucks. Of course, users can install Cygwin but one of most attractive things about the Taskfile format is not having to install external software to run the tasks. Hopefully, [Microsoft’s native bash shell in Windows 10](http://www.howtogeek.com/249966 how-to-install-and-use-the-linux-bash-shell-on-windows-10/) can do work well for us in the future.

*****

### Collaboration

The Taskfile format is something I’d love to see become more widespread and it’d be awesome if we could all come together on a standard of sorts. Things like simple syntax highlighting extensions or best practices guide would be awesome to formalise.

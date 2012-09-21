# sub: an old (new) way to organize programs

Sub is a model for setting up shell programs that use subcommands, like `git` or `rbenv` using bash. However, it does not require you to write shell scripts in bash, just the skeleton around sub is bash. This repo is an example of how you can create your own sub-style programs.

A sub program is run at the command line using this style:

    $ [name of program] [subcommand] [(args)]

Here's some quick examples:

    $ rbenv                    # prints out version number, usage, and subcommands
    $ rbenv versions           # runs the "versions" subcommand
    $ rbenv shell 1.9.3-p194   # runs the "shell" subcommand, passing "1.9.3-p194" as an argument

Each subcommand maps to a separate, standalone executable program. Sub programs are laid out like so:

    .
    ├── bin               # contains the main executable for your program
    ├── completions       # (optional) bash/zsh completions
    ├── libexec           # where the subcommand executables are
    └── share             # static data storage

## Subcommands

Each subcommand executable does not necessary need to be in bash. It can be any program, shell script, or even a symlink. It just needs to run.

...

## Autocompletion

Autocompletion in your shell is built in for free.

...

## Aliases

Creating shortcuts for commands is easy, just symlink the shorter version you'd like to run inside of your `libexec` directory.

...

## Installing

Clone this repo, and run:

`./rename.sh [name of your executable]`

From there you may want to wipe the git history clean and start anew: `rm -rf .git`.

## License

MIT. See `LICENSE`.

# sub: a delicious way to organize programs

Sub is a model for setting up shell programs that use subcommands, like `git` or `rbenv` using bash. Making a sub does not require you to write shell scripts in bash, you can write subcommands in any scripting language you prefer.

A sub program is run at the command line using this style:

    $ [name of program] [subcommand] [(args)]

Here's some quick examples:

    $ rbenv                    # prints out usage and subcommands
    $ rbenv versions           # runs the "versions" subcommand
    $ rbenv shell 1.9.3-p194   # runs the "shell" subcommand, passing "1.9.3-p194" as an argument

Each subcommand maps to a separate, standalone executable program. Sub programs are laid out like so:

    .
    ├── bin               # contains the main executable for your program
    ├── completions       # (optional) bash/zsh completions
    ├── libexec           # where the subcommand executables are
    └── share             # static data storage

## Subcommands

Each subcommand executable does not necessarily need to be in bash. It can be any program, shell script, or even a symlink. It just needs to run.

Here's an example of adding a new subcommand. Let's say your sub is named `rush`. Run:

    touch libexec/rush-who
    chmod a+x libexec/rush-who

Now open up your editor, and dump in:

``` bash
#!/usr/bin/env bash
set -e

who
```

Of course, this is a simple example... but now `rush who` should work!

    $ rush who
    qrush     console  Sep 14 17:15 

You can run *any* executable in the `libexec` directly, as long as it follows the `NAME-SUBCOMMAND` convention. Try out a Ruby script or your favorite language!

## What's on your sub

You get a few commands that come with your sub:

* `commands`: Prints out every subcommand available.
* `completions`: Helps kick off subcommand autocompletion.
* `help`: Document how to use each subcommand.
* `init`: Shows how to load your sub with autocompletions, based on your shell.
* `shell`: Helps with calling subcommands that might be named the same as builtin/executables.

If you ever need to reference files inside of your sub's installation, say to access a file in the `share` directory, your sub exposes the directory path in the environment, based on your sub name. For a sub named `rush`, the variable name will be `_RUSH_ROOT`.

Here's an example subcommand you could drop into your `libexec` directory to show this in action: (make sure to correct the name!)

``` bash
#!/usr/bin/env bash
set -e

echo $_RUSH_ROOT
```

You can also use this environment variable to call other commands inside of your `libexec` directly. Composition of this type very much encourages reuse of small scripts, and keeps scripts doing *one* thing simply.

## Self-documenting subcommands

Each subcommand can opt into self-documentation, which allows the subcommand to provide information when `sub` and `sub help [SUBCOMMAND]` is run.

This is all done by adding a few magic comments. Here's an example from `rush who` (also see `sub commands` for another example):

``` bash
#!/usr/bin/env bash
# Usage: sub who
# Summary: Check who's logged in
# Help: This will print out when you run `sub help who`.
# You can have multiple lines even!
#
#    Show off an example indented
#
# And maybe start off another one?

set -e

who
```

Now, when you run `sub`, the "Summary" magic comment will now show up:

    usage: sub <command> [<args>]

    Some useful sub commands are:
       commands               List all sub commands
       who                    Check who's logged in

And running `sub help who` will show the "Usage" magic comment, and then the "Help" comment block:

    Usage: sub who

    This will print out when you run `sub help who`.
    You can have multiple lines even!

       Show off an example indented

    And maybe start off another one?

That's not all you get by convention with sub...

## Autocompletion

Your sub loves autocompletion. It's the mustard, mayo, or whatever topping you'd like that day for your commands. Just like real toppings, you have to opt into them! Sub provides two kinds of autocompletion:

1. Automatic autocompletion to find subcommands (What can this sub do?)
2. Opt-in autocompletion of potential arguments for your subcommands (What can this subcommand do?)

Opting into autocompletion of subcommands requires that you add a magic comment of (make sure to replace with your sub's name!):

    # Provide YOUR_SUB_NAME completions

and then your script must support parsing of a flag: `--complete`. Here's an example from rbenv, namely `rbenv whence`:

``` bash
#!/usr/bin/env bash
set -e
[ -n "$RBENV_DEBUG" ] && set -x

# Provide rbenv completions
if [ "$1" = "--complete" ]; then
  echo --path
  exec rbenv shims --short
fi

# lots more bash...
```

Passing the `--complete` flag to this subcommand short circuits the real command, and then runs another subcommand instead. The output from your subcommand's `--complete` run is sent to your shell's autocompletion handler for you, and you don't ever have to once worry about how any of that works!

Run the `init` subcommand after you've prepared your sub to get your sub loading automatically in your shell.

## Shortcuts

Creating shortcuts for commands is easy, just symlink the shorter version you'd like to run inside of your `libexec` directory.

Let's say we want to shorten up our `rush who` to `rush w`. Just make a symlink!

    cd libexec
    ln -s rush-who rush-w

Now, `rush w` should run `libexec/rush-who`, and save you mere milliseconds of typing every day!

## Prepare your sub

Clone this repo:

    git clone git://github.com/37signals/sub.git [name of your sub]
    cd [name of your sub]
    ./prepare.sh [name of your sub]

The prepare script will run you through the steps for making your own sub. Also, don't call it `sub`, by the way! Give it a better name.

## Install your sub

So you've prepared your own sub, now how do you use it? Here's one way you could install your sub in your `$HOME` directory:

    cd
    git clone [YOUR GIT HOST URL]/sub.git .sub

For bash users:

    echo 'eval "$($HOME/.sub/bin/sub init -)"' >> ~/.bash_profile
    exec bash

For zsh users:

    echo 'eval "$($HOME/.sub/bin/sub init -)"' >> ~/.zshenv
    source ~/.zshenv

You could also install your sub in a different directory, say `/usr/local`. This is just one way you could provide a way to install your sub.

## License

MIT. See `LICENSE`.

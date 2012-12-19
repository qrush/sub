#compdef sub

# This completion file should be linked to a directory in ZSH fpath
# and named `_sub`.

case $CURRENT in
    2)
        local cmds
        local -a commands
        cmds=$(sub commands)
        commands=(${(ps:\n:)cmds})
        _wanted command expl "sub command" compadd -a commands
        ;;
    *)
        local cmd subcmds
        local -a commands
        cmd=${words[2]}
        subcmds=$(sub completions ${words[2,$(($CURRENT - 1))]})
        commands=(${(ps:\n:)subcmds})
        _wanted subcommand expl "sub $cmd subcommand" compadd -a commands
        ;;
esac

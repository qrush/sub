_sub() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(sub commands)" -- "$word") )
  else
    local command="${COMP_WORDS[@]:1:${#COMP_WORDS[@]}-2}"
    local completions="$(sub completions $command)"
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  fi
}

complete -F _sub sub

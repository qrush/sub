_sub() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(sub commands)" -- "$word") )
  elif [ "$COMP_CWORD" -gt 1 ]; then
    COMPREPLY=( $(compgen -W "$(sub commands ${COMP_WORDS[@]})" -- "$word") )
  fi
}

complete -F _sub sub

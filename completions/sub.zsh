if [[ ! -o interactive ]]; then
    return
fi

compctl -K _sub sub

_sub() {
  local word words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(sub commands)"
  elif [ "${#words}" -gt 2 ]; then
    completions="$(sub commands "$words")"
  fi

  reply=("${(ps:\n:)completions}")
}

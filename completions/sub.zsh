if [[ ! -o interactive ]]; then
    return
fi

compctl -K _sub sub

_sub() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(sub commands)"
  else
    completions="$(sub completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}

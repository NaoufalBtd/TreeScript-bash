spinner() {
  local i sp n
  sp='/-\|'
  n=${#sp}
  printf ' '
  while sleep 0.1; do
    printf "%s\b" "${sp:i++%n:1}"
  done
}
setCurrFolderName() {
  currFolderName=$(basename $1)
  [[ "$currFolderName" = "." ]] && currFolderName=$(basename $PWD) # in case we enter a relative path
}
box_out() {
  local s=("$@") b w
  local entries
  for val in "${s[@]}"; do
    [[ $val ]] && entries+=("$val")
  done
  local rootPrefix
  if [[ "$i" -eq "1" ]]; then
    topPrefix=" "
    rootPrefix="╔"
    bottomPrefix="║"
  elif [[ "$i" -eq "$filesCount" ]]; then
    topPrefix="║"
    rootPrefix="╚"
    bottomPrefix=" "

  else
    topPrefix="║"
    rootPrefix="╠"
    bottomPrefix="║"

  fi
  for l in "${entries[@]}"; do
    ((w < ${#l})) && {
      b="$l"
      w="${#l}"
    }
  done

  tput setaf 3
  echo "$topPrefix ╭─${b//?/─}─╮
$topPrefix │ ${b//?/ } │"
  headerBorder=$(printf '─%.0s' $(seq 0 $((w + 1))))
  local i="0"
  for l in "${entries[@]}"; do
    if [[ "$i" -eq "0" ]] && [[ "${#entries[@]}" -gt "1" ]]; then
      printf "╠═│ %s${bold}%*s${normal}%s │ \n╠═│$headerBorder│\n╠═│ %${w}s │\n" "$currFileColor" "-$w" "$l" "$(tput setaf 3)"
    elif [[ "$i" -eq "0" ]]; then
      printf "╠═│ %s%*s%s │\n" "$currFileColor" "-$w" "$l" "$(tput setaf 3)"
    else
      printf "╠═│ %s%*s │\n" "$(tput setaf 3)" "-$w" "$l"
    fi
    i=$((i + 1))
  done
  echo "$bottomPrefix │ ${b//?/ } │
$bottomPrefix ╰─${b//?/─}─╯"
  tput sgr 0
}
getFileColorByType() {
  filePath=$1
  res=$(file $filePath)
  fileType=${res#*: }
  if [[ "${fileType}" =~ script ]]; then
    currFileColor=$red
  elif [[ "${fileType}" =~ symbol ]]; then
    currFileColor=$magenta
  elif [[ "${fileType}" =~ directory ]]; then
    currFileColor=$blue
  elif [[ "${fileType}" =~ image ]]; then
    currFileColor=$cyan
  elif [[ "${fileType}" =~ archive ]]; then
    currFileColor=$black
  elif [[ "${fileType}" =~ text ]]; then
    currFileColor=$white
  else
    currFileColor=$white
  fi
}

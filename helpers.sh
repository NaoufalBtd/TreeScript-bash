setFilePermission() {
  [[ "$withPermission" -eq "1" ]] && filePermission="[ $(stat -c "%A" $currentFolder/$file) ]"
}
setFileSize() {
  [[ "$withSize" -eq "1" ]] && fileSize="$(stat -c "%B" $currentFolder/$file)"
}
setFolderName() {
  currFolderName=$(basename $1)
  [[ "$currFolderName" = "." ]] && currFolderName=$(basename $PWD) # in case we enter a relative path
}
setTreeRootPrefix() {
  setFolderName $1
  local rightPrefix leftPrefix
  if [[ "$2" = $ADVANCED_MODE ]]; then
    leftPrefix="▣═════╣"
    rightPrefix="╠═════"
  else
    rightPrefix="━━━━━━━"
    leftPrefix="▐━━━━━━"
  fi
  folderNameAsPresfix="$leftPrefix Current Folder: $currFolderName $rightPrefix"
  spaces=""
  for j in $(seq 1 ${#folderNameAsPresfix}); do spaces="$spaces "; done
}
####### Helpers ##########

showFilesGrid() {
  tput clear
  export foundedFolds=()
  export filesName=()
  exportfilesCount=$(ls $1 | wc -w)
  setTreeRootPrefix $initFolder $ADVANCED_MODE
  local i="0"
  while read file; do
    i=$((i + 1))
    getFileColorByType "$currentFolder/$file"
    if [[ "$withPermission" -eq "1" ]]; then
      setFilePermission
      filePermissionInfo="Permission: $filePermission"
    fi
    if [[ "$withSize" -eq "1" ]]; then
      setFileSize
      fileSizeInfo="Size: ${fileSize} Bytes"
    fi
    if [[ -d "$currentFolder/$file" ]]; then
      local subFilesCount=$(ls $currentFolder/$file | wc -w)
      box_out "$file (subFiles: $subFilesCount)" "$filePermissionInfo" "$fileSizeInfo"
      [[ $subFilesCount -gt "0" ]] && foundedFolds+=("$file")
    else
      box_out "$file" "$filePermissionInfo" "$fileSizeInfo"
    fi
  done <<<"$(ls $1)" >.tmpFilesGrid
  awk -F : -v var="$folderNameAsPresfix" -v s="$spaces" -v md=$((i * 5 / 2)) '{ if( NR == md ){ print var $0} else {print s $0}}' .tmpFilesGrid
  rm .tmpFilesGrid
}
showOptionPrompt() {
  tput setaf 3 # Set a foreground colour using ANSI escape
  echo "Total Result: $1. Founded Folders: $2"
  tput sgr0

  cursPosition=$(tput lines)
  tput cup $cursPosition 17
  tput rev # Set reverse video mode
  echo "C H O O S E - O P T I O N"
  tput sgr0

  tput cup $((cursPosition + 2)) 15
  cursPosition=$((cursPosition + 1))
  echo "0. Back To Parent Folder"
  for i in $(seq 0 $((${#foundedFolds[@]} - 1))); do
    tput cup $((cursPosition + 1)) 15
    echo "$((i + 1)). ${foundedFolds[i]^^}"
  done
  echo -en "Enter Your Choice: "
}
# a function that listen to key press and wait to press enter
# if the user press enter the function will return the pressed key

captureKeyPress() {
  while true; do
    read -rsn1 input
    echo -en "$input"
    pressedKey+="$input"
    if [[ "$input" = "" ]]; then
      break
    fi
  done
}

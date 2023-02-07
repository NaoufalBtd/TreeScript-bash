#!/bin/bash/

source ./variables.sh
source ./utils.sh
source ./helpers.sh

showFileTree() {
  local currentFolder=$1
  local currentPrefix=$2
  setFolderName $currentFolder
  seperator="┃   ┃  "
  local filesNum=$(ls $currentFolder | wc -w)
  local index="0"
  ls $currentFolder | while read file; do
    ### assign the appropriate prefix
    index=$((index + 1))
    if [[ "$filesNum" -eq "1" ]]; then
      prefix="━"
      foldPrefix="━"
    elif [[ "$index" -eq "$filesNum" ]]; then
      prefix="┗━"
      foldPrefix="┗━"
    elif [[ "$index" -eq "1" ]]; then
      prefix="┏━"
      foldPrefix="┏━"
    else
      foldPrefix="╞═"
      prefix="┣━"
    fi

    if [[ -d "$currentFolder/$file" ]]; then
      getFileColorByType "$currentFolder/$file"        # setting up the color of file by type
      subFilesCount=$(ls $currentFolder/$file | wc -w) # get the number of the files in the current fold
      setFilePermission                                # Assigning the file's permission detail to variable filePermission
      echo -e "$currentPrefix$prefix ${currFileColor}${bold}${file}${colorOff} ${italic}$filePermission ($subFilesCount)${normal} "
      if [[ -n $deepthLevel ]] && [[ "$currDepth" -lt "$deepthLevel" ]] || [[ -z $deepthLevel ]]; then # Check if depth is setted and that next folder dosn't exceed the depth'
        currDepth=$((currDepth + 1))
        local childFolder="$currentFolder/$file"
        local newPrefix="$currentPrefix$seperator"
        showFileTree "$childFolder" "$newPrefix"
        currDepth=$((currDepth - 1))
      fi
    else
      getFileColorByType "$currentFolder/$file"
      echo -e "$currentPrefix$prefix ${currFileColor}$file${colorOff} $filePermission"
    fi
    if [[ ! "$isSpaceAdded" ]]; then
      isSpaceAdded="true"
      currentPrefix="$spaces$currentPrefix"
    fi
  done
}

runAdvancedMode() {
  local currentFolder=$1
  local index="1"
  showFilesGrid $currentFolder
  # espeak "wich file you want to look at next"
  local subFilesCount=$(ls $currentFolder | wc -w)
  showOptionPrompt "$subFilesCount" "${#foundedFolds[@]}"
  local pressedKey
  captureKeyPress
  echo "pressed key is $pressedKey"
  if [[ "$pressedKey" -eq "0" ]]; then
    runAdvancedMode ${currentFolder%/*}

  elif [[ "$pressedKey" -le ${#foundedFolds[@]} ]]; then
    local index=$((optionNumber - 1))
    runAdvancedMode "$currentFolder/${foundedFolds[index]}"
  else
    echo -e "${bleu}Info:${colorOff} the choosen number isn't exist, Please Repeat again"
    startVoiceListening 6
  fi
}

### Parse Entred Script Options
while getopts ":h:mpsl:" flag; do
  case $flag in
  m) # set advanced view mode
    mode="advanced"
    ;;
  p)
    withPermission="1"
    ;;
  s)
    withSize="1"
    ;;
  l)
    # Assaign the deepth level of visualised folder
    if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
      deepthLevel=$OPTARG
    else
      echo "Invalid options: -$flag  $OPTARG" >&2
      exit
    fi
    ;;
  esac
done
shift "$((OPTIND - 1))"
### Main
tput clear
initFolder="$1"
if [[ "$initFolder" = "" ]]; then
  initFolder="./"
elif [[ ! -d "$initFolder" ]]; then
  echo "Invalid folder path" >&2
  exit
fi
initFolderChildNum=$(ls $initFolder | wc -w)
if [[ "$initFolderChildNum" -gt "1" ]]; then
  if [[ $mode == "advanced" ]]; then
    runAdvancedMode $initFolder
  else
    setTreeRootPrefix $initFolder
    echo -n "$folderNameAsPresfix"
    counter="1"
    showFileTree $initFolder "$prefix"
  fi
else
  echo -e "${yellow}Warning:${colorOff} 2>&1 the Current Folder is Empty. Please Select Another One"
fi

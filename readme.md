## Introduction

This shell code is a script that helps to visualize and organize files in a terminal. The script uses ANSI color codes and escape sequences to format the text output.

## Prerequisites

The script requires the tput and file commands, which are commonly available on most Unix-based systems.

## Variables

The following variables are defined in the script:

- **deepthLevel** - The level of the current directory
- **currDepth** - The current directory
- **ADVANCED_MODE** - A flag that determines if the advanced mode is enabled
- colorOff, black, red, green, yellow, blue, magenta, cyan, and white - ANSI color codes for text formatting
- bold, italic, and normal - ANSI codes for text decoration

## Functions

The following functions are defined in the code:

- setCurrFolderName - A function that sets the current folder name based on the input folder path
- box_out - A function that outputs a box with the input string
- getFileColorByType - A function that sets the color of a file based on its type

## Usage

The code can be executed in the terminal using the following command:

```shell
bash ./main.sh
```

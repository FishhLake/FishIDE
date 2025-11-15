#!/bin/bash

# FishIDE, a perfect IDE made in GNU Nano 8.7 in BASH specifically for FISH Terminal
# FishIDE Version 2 — full release.

# COLORS
FISHIDE_COLOR="\e[38;2;0;166;255m"
FISHIDE_BORDER="\e[38;2;0;119;204m"
FISHIDE_HIGHLIGHT="\e[38;2;51;207;255m"
RESET="\e[0m"

echo -e "${FISHIDE_COLOR} Welcome to FishIDE${RESET}"
echo -e "${FISHIDE_HIGHLIGHT} ----------------------------------------------------------------------------- ${RESET}"
echo

# COMMANDS // FishScript

print() { echo "$@"; }                          # prints

makefolder() { mkdir "$1"; }                     # makes a folder

makefile() { touch "$1"; }                       # makes a file

goto() { cd "$1" || print "directory not found or doesn't exist"; }   # changes directory

goback() {
    steps=${1:-1}
    for ((i=0; i < steps; i++)); do
        cd ..
    done
}

delete() {
    if [[ -z "$1" ]]; then
        echo "fish says: no directory found"
        return 1
    fi

    if [[ "$1" = "/" ]]; then
        echo "the fish guardian has saved you."
        return 1
    fi

    echo "Delete '$1'? (y/N)"
    read answer
    [[ "$answer" =~ ^[Yy]$ ]] || return

    sudo rm -rf -- "$1"
}

close() { exit; }

wait() { sleep "$1"; }

view() { ls; }

math() { echo "$(( $* ))"; }

update() { sudo pacman -Syu; }

get() { git clone "$@"; }

install() { sudo pacman -S "$@"; }

run() { chmod +x "$1" && ./"$1"; }

fishPrograms() { sudo pacman -S git; }

copy() { cp "$@"; }

connect() { ssh "$@"; }

help() {
    echo "fishIDE is a lightweight, powerful IDE toolbox."
}

# |--------------------------------------------------------|
# |  -!- CODE WORKSPACE AREA -!- CODE WORKSPACE AREA -!-   |
# |--------------------------------------------------------|

help

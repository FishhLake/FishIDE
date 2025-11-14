# FishIDE, a perfect IDE made in GNU Nano 8.6 in BASH specifcially FISH Terminal
# FishIDE Version 1, Beta.

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Colors
FISHIDE_COLOR="\e[38;2;0;166;255m"
FISHIDE_BORDER="\e[38;2;0;119;204m"
FISHIDE_HIGHLIGHT="\e[38;2;51;207;255m"
RESET="\e[0m"

#--------------------------------------------------------
echo -e "${FISHIDE_COLOR} Welcome to FishIDE${RESET}"
echo -e "${FISHIDE_HIGHLIGHT} 🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟🐟${RESET}"
echo
#--------------------------------------------------------

#COMMANDS
print() { echo "$@"; }
mf() { mkdir "$1"; }
goto() { cd "$1" || Print "Directory not found"; }
goback() {
    steps=${1:-1}
    for ((i=0; i<steps; i++)); do
        cd ..
    done
}
delete() { rm -rf "$1"; }
close() { exit; }
wait() { sleep "$1"; }
view() { ls; }
math() {
    echo "$(( $* ))"
}
update() {
    sudo pacman -Syu
}

# |--------------------------------------------------------|
# |  -!- CODE WORKSPACE AREA -!- CODE WORKSPACE AREA -!-   |
# |--

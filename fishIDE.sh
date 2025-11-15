#!/bin/bash

# FishIDE, a perfect IDE.Toolkit.Shell made in GNU Nano 8.7 in BASH
# FishIDE Version 5

#COLORS
FISHIDE_COLOR="\e[38;2;40;95;160m"
FISHIDE_BORDER="\e[38;2;100;130;170m"
FISHIDE_HIGHLIGHT="\e[38;2;30;150;170m"
RESET="\e[0m"

# STATUS COLORS
FISHIDE_OK="\e[38;2;0;140;95m"
FISHIDE_ERROR="\e[38;2;180;50;50m"
FISHIDE_WARN="\e[38;2;200;150;40m"

echo -e "${FISHIDE_COLOR} Welcome to FishIDE v4${RESET}"
echo -e "${FISHIDE_HIGHLIGHT} ----------------------------------------------------------------------------- ${RESET}"
echo

status_ok() {
    echo -e "${FISHIDE_OK}✔ fishIDE: $1${RESET}"
}

status_error() {
    echo -e "${FISHIDE_ERROR}✘ fishIDE: $1${RESET}"
}

status_warn() {
    echo -e "${FISHIDE_WARN}! fishIDE: $1${RESET}"
}
# PROGRESS BAR
progress_bar() {
    total=$1
    for ((i=1; i<=total; i++)); do
        percentage=$(( i * 100 / total ))
        bar=$(printf "%-${i}s" "#" )
        spaces=$(printf "%$((total-i))s" "")
        echo -ne "${FISHIDE_HIGHLIGHT}[${bar}${spaces}] ${percentage}%\r${RESET}"
        sleep 0.05
    done
    echo
}
# FISH EXECUTE // SYNTAX HIGHLIGHTER
fish_execute() {
    command=$1
    shift

    if $command "$@"; then
        status_ok "$command completed"
    else
        status_error "$command failed"
    fi
}


# COMMANDS // FishScript
print() { echo "$@"; }                          

makefolder() { 
    mkdir "$1" && status_ok "created folder '$1'" || status_error "failed to create folder"
}

makefile() { 
    touch "$1" && status_ok "created file '$1'" || status_error "failed to create file"
}

goto() { 
    cd "$1" || { status_error "directory not found"; return; }
    status_ok "moved to '$1'"
}

goback() {
    steps=${1:-1}
    for ((i=0; i < steps; i++)); do
        cd ..
    done
    status_ok "went back $steps step(s)"
}

delete() {
    if [[ -z "$1" ]]; then
        status_warn "fish says: no directory found"
        return 1
    fi

    if [[ "$1" = "/" ]]; then
        status_warn "the fish guardian has saved you."
        return 1
    fi

    echo "Delete '$1'? (y/N)"
    read answer
    [[ "$answer" =~ ^[Yy]$ ]] || { status_warn "cancelled"; return; }

    progress_bar 20
    sudo rm -rf -- "$1" && status_ok "deleted '$1'" || status_error "delete failed"
}

close() { exit; }

wait() { sleep "$1"; status_ok "waited $1 second(s)"; }

view() { ls; status_ok "listed files"; }

math() {
    expr="$*"
    result=$(echo "$expr" | bc)
    echo "$result"
    status_ok "✔ math complete"
}

update() { 
    echo -e "${FISHIDE_HIGHLIGHT}Updating system...${RESET}"
    progress_bar 30
    sudo pacman -Syu && status_ok "system updated" || status_error "update failed"
}

get() { git clone "$@" && status_ok "cloned repo" || status_error "clone failed"; }

install() { sudo pacman -S "$@" && status_ok "installed package" || status_error "installation failed"; }

run() {
    case "$1" in
        *.py)  python3 "$1" ;;
        *.lua) lua "$1" ;;
        *.sh)  bash "$1" ;;
        *)     echo "✘ unknown file type" ;;
    esac
}


fishPrograms() { sudo pacman -S git bc && status_ok "installed fish programs"; }

copy() { cp "$@" && status_ok "copied" || status_error "copy failed"; }

connect() { ssh "$@" && status_ok "connected" || status_error "connection failed"; }

help() {
    echo "fishIDE v5 Interactive Shell"
    echo
    echo "Commands:"
    echo "  print <msg>       - print a message"
    echo "  makefile <name>   - create a new file"
    echo "  makefolder <dir>  - create new folder"
    echo "  goto <dir>        - cd into folder"
    echo "  goback <n>        - go back directories"
    echo "  delete <file>     - delete file/dir"
    echo "  view              - list files"
    echo "  math <expr>       - calculate number"
    echo "  get <url>         - git clone"
    echo "  install <pkg>     - pacman install"
    echo "  run <file>        - execute file"
    echo "  connect <user@ip> - SSH connect"
    echo "  close/exit        - exit shell"
}

Game() { 
makefile SECONDSCOUNTER.sh;
echo "count=0" >> SECONDSCOUNTER.sh;
echo "while true; do" >> SECONDSCOUNTER.sh;
echo "    count=\$((count+1))" >> SECONDSCOUNTER.sh;
echo "    echo \"\$count\"" >> SECONDSCOUNTER.sh;
echo "    sleep 1" >> SECONDSCOUNTER.sh;
echo "done" >> SECONDSCOUNTER.sh;
    chmod +x SECONDSCOUNTER.sh
    ./SECONDSCOUNTER.sh
}

# Fshell // FishShell
while true; do
    echo -ne "${FISHIDE_COLOR}fishIDE> ${RESET}"
    read -r cmd args

    case "$cmd" in
        help) help ;;
        print) print $args ;;
        makefile) makefile $args ;;
        makefolder) makefolder $args ;;
        goto) goto $args ;;
        goback) goback $args ;;
        delete) delete $args ;;
        view) view ;;
        wait) wait $args ;;
        math) math $args ;;
        get) get $args ;;
        install) install $args ;;
        run) run $args ;;
        copy) copy $args ;;
        connect) connect $args ;;
        game) Game ;;
        close|exit) close ;;
        update) update ;;
        fishPrograms) fishPrograms ;;
        "") ;;
        *) echo -e "${FISHIDE_ERROR}Unknown command: $cmd${RESET}" ;;
    esac
done

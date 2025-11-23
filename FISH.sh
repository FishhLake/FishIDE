#!/bin/bash
# FISH v4 ;; 

# STARTING DIRECTORY ;; 
DIRECTORY="$HOME/FISH/"
cd "$DIRECTORY" 2>/dev/null

# COLORS ;; 
FISH_COLOR="\e[38;2;40;95;160m"
FISH_BORDER="\e[38;2;100;130;170m"
FISH_HIGHLIGHT="\e[38;2;30;150;170m"
RESET="\e[0m"

# STATUS COLORS ;;
FISH_OK="\e[38;2;0;140;95m"
FISH_ERROR="\e[38;2;180;50;50m"
FISH_WARN="\e[38;2;200;150;40m"
    
    # BANNER ;;
    cols=$(tput cols)
    line="${FISH_BORDER}$(printf '─%.0s' $(seq 1 $cols))${RESET}"

    title="Welcome to FISH v4"
    subtitle="Lightweight • Fast • Scriptable • 2025"

    title_pad=$(( (cols - ${#title}) / 2 ))
    sub_pad=$(( (cols - ${#subtitle}) / 2 ))

    echo -e "$line"
    echo -e "$(printf "%*s" "$title_pad")${FISH_COLOR}${title}${RESET}"
    echo -e "$(printf "%*s" "$sub_pad")${FISH_BORDER}${subtitle}${RESET}"
    echo -e "$line"
    echo
 
ok() { echo -e "${FISH_OK}✔ $1${RESET}"; }
err() { echo -e "${FISH_ERROR}✘ $1${RESET}"; }
warn() { echo -e "${FISH_WARN}! $1${RESET}"; }

# PROGRESS BAR ;;
progress_bar() {
    total=$1
    width=40
    for ((i=1;i<=total;i++)); do
        percent=$(( i * 100 / total ))
        filled=$(( percent * width / 100 ))
        bar=$(printf "%-${width}s" | tr ' ' '#')
        bar="${bar:0:filled}"

        echo -ne "${FISH_HIGHLIGHT}[${bar}] ${percent}%\r${RESET}"
        sleep 0.03
    done
    echo
}

# COMMANDS ;;
print() { echo "$@"; }
makefile() {
    [[ -z "$1" ]] && { err "filename required"; return; }
    touch "$1" && ok "created file $1"
}
makefolder() {
    [[ -z "$1" ]] && { err "directory name required"; return; }
    mkdir -p "$1" && ok "created folder $1"
}
goto() {
    [[ -z "$1" ]] && { err "path required"; return; }
    cd "$1" 2>/dev/null || { err "directory not found"; return; }
}
goback() {
    steps=${1:-1}
    for ((i=0;i<steps;i++)); do
        cd .. 2>/dev/null || { err "already at root"; return; }
    done
}
delete() {
    target="$1"

    [[ -z "$target" ]] && { err "nothing to delete"; return; }

    protected=("/" "/home" "/root" "/etc" "/usr" "/bin" "/sbin" "/lib" "/lib64" "." "..")

    for p in "${protected[@]}"; do
        [[ "$target" == "$p" ]] && { err "protected path: $p"; return; }
    done

    if [[ ! -e "$target" ]]; then
        err "file not found"
        return
    fi

    echo "Delete '$target'? (y/N)"
    read -r ans

    [[ "$ans" =~ ^[Yy]$ ]] || { warn "cancelled"; return; }
    rm -rf -- "$target" && ok "deleted $target"
}
view() { echo *;  }
wait() { sleep "${1:-1}"; ok "waited ${1:-1} second(s)"; }
math() {
    result=$(echo "$*" | bc -l 2>/dev/null)
    [[ -z "$result" ]] && { err "invalid math expression"; return; }
    echo "$result"
}
update() { 
    echo -e "${FISH_HIGHLIGHT}Updating system...${RESET}"
    progress_bar 30
    sudo pacman -Syu && ok "system updated" || err "update failed"
}
get() { git clone "$@" && ok "cloned repo" || err "clone failed"; }
install() { sudo pacman -S "$@" && ok "installed" || err "install failed"; }
uninstall() {
    if [ $# -eq 0 ]; then
        err "usage: uninstall <package>"
        return 1
    fi
    sudo pacman -Rdd "$@" && ok "uninstalled" || err "uninstall failed"
}
execute() {
    file="$1"

    if [[ -z "$file" ]]; then
        echo "Usage: run <file>"
        return 1
    fi

    if [[ "$file" == *.c ]]; then
        out="${file%.c}"

        echo "[FISH] Compiling $file..."
        if gcc "$file" -o "$out" -lm; then
            echo "[FISH] Running $out..."
            "./$out"
        else
            echo "[FISH] Compilation failed."
        fi
        return
    fi

    if [[ "$file" == *.sh ]]; then
        bash "$file"
        return
    fi

    if [[ "$file" == *.py ]]; then
        python3 "$file"
        return
    fi

}
copy() { cp "$1" "$2" && ok "copied" || err "copy failed"; }
move() { mv "$1" "$2" && ok "moved" || err "move failed"; }
connect() { ssh "$@" && ok "connected" || err "connection failed"; }
edit() { nano "$1"; }
whereami() { pwd; }
sysinfo() {
    echo -e "${FISH_HIGHLIGHT}"
    echo "User: $USER"
    echo "Shell: FISH v4"
    echo "OS: $(uname -o)"
    echo "Kernel: $(uname -r)"
    echo "CPU: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2)"
    echo "RAM: $(free -h | awk '/Mem/ {print $3 "/" $2}')"
    echo -e "${RESET}"
}
disks() { lsblk; }
mdisks() { sudo fdisk -l; }
info() { echo "FISH v4 (2025)"; }
open() {
    [[ -z "$1" ]] && { err "file required"; return; }
    [[ ! -e "$1" ]] && { err "file not found"; return; }

    case "$1" in
        *.txt|*.md|*.sh|*.py|*.lua) nano "$1" ;;
        *.png|*.jpg|*.jpeg) xdg-open "$1" ;;
        *) xdg-open "$1" 2>/dev/null || err "cannot open file" ;;
    esac
}
help() {
    echo "FISH v4 Commands:"
    echo "  print <msg>" ## PRINTS MESSAGE ;;
    echo "  makefile <name>" ## MAKES A FILE ;;
    echo "  makefolder <dir>" ## MAKES A FOLDER ;;
    echo "  goto <dir>" ## GOES TO A DIRECTORY ;;
    echo "  goback <n>" ## GOES BACK n DIRECTORIES ;;
    echo "  delete <file>" ## DELETES A FILE(s) ;;
    echo "  view" ## VIEW DIRECTORY ;;
    echo "  math <expr>" ## MATH ;; 
    echo "  install <pkg>" ## INSTALL A PACKAGE/FILE ;; 
    echo "  get <url>" ## SIMILAR TO GIT CLONE ( GITHUB REPO ) ;;  
    echo "  execute <file>" ## AUTO COMPILES / EXECUTES FILE ;;
    echo "  edit <file>" ## EDITS FILE IN NANO ;;
    echo "  open <file>" ## OPENS A FILE ;;
    echo "  connect <user@host>" ## CONNECTS TO COMPUTERS / SERVERS USING SSH ;;
    echo "  sysinfo" ## SHOWS YOUR HARDWARE ;;
    echo "  disks" ## SHOWS YOUR PARTITIONS USING LSBLK ;;
    echo "  mdisks" ## MANAGE DISKS USING FDISK ;; 
    echo "  info" ## INFORMATION ABOUT SHELL ;;
    echo "  whereami" ## SHOWS YOUR CURRENT DIRECTORY ;; 
    echo "  close/exit" ## CLOSES THE SHELL ;; 
    echo "  clear     " ## CLEARS THE SCREEN ;;
    echo "  web <address>" ## SURF THE WEB ;;
    echo "  games" ## GAMES LIST ;;
    echo "  history" ##displays history ;;
}
close() { exit 0; }
clear() {
    printf "\033[2J\033[H"
}
web() {
    [[ -z "$1" ]] && { err "URL required"; return; }
    xdg-open "https://$1" >/dev/null 2>&1 &
    ok "opening $1"
}
games() { 

      echo -e "${FISH_COLOR}Spinning Cube.c ${RESET}"
      echo -e "${FISH_COLOR}SNAKE.c ${RESET}"
      echo -e "${FISH_COLOR}Rock Paper Scissors ${RESET}"

}
# FISH SHELL ;;
while true; do
    
   echo -ne "${FISH_BORDER}${PWD}${RESET} "
    echo -ne "${FISH_COLOR}⟦FISH⟧» ${RESET}"
    read -r line

    line="$(echo "$line" | sed 's/^[ \t]*//;s/[ \t]*$//')"

    [[ -z "$line" ]] && continue

    if [[ "${line: -1}" != ";" ]]; then
        err "missing semicolon ';'"
        continue
    fi

    line="${line%?}"
     
    CMD="$(echo "$line" | cut -d' ' -f1 | tr '[:lower:]' '[:upper:]')"
    ARGS="$(echo "$line" | cut -d' ' -f2-)"

    case "$CMD" in
        PRINT) print $ARGS ;;
        MAKEFILE) makefile $ARGS ;;
        MAKEFOLDER) makefolder $ARGS ;;
        GOTO) goto $ARGS ;;
        GOBACK) goback $ARGS ;;
        DELETE) delete $ARGS ;;
        VIEW) view  ;;
        WAIT) wait $ARGS ;;
        MATH) math $ARGS ;;
        GET) get $ARGS ;;
        INSTALL) install $ARGS ;;
        EXECUTE) execute $ARGS ;;
        COPY) copy $ARGS ;;
        MOVE) move $ARGS ;;
        CONNECT) connect $ARGS ;;
        UPDATE) update ;;
        SYSINFO) sysinfo ;;
        DISKS) disks ;;
        MDISKS) mdisks ;;
        EDIT) edit $ARGS ;;
        OPEN) open $ARGS ;;
        WHEREAMI) whereami ;;
        CLOSE|EXIT) close ;;
        CLEAR) clear ;;
        WEB) web $ARGS ;;
        GAMES) games ;;
        UNINSTALL) uninstall $ARGS ;;
        HELP) help ;;
        *)
            err "Unknown command: $CMD"
            ;;
    esac
done

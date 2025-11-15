#!/bin/bash
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
set -o vi

#FISH v6

# COLORS
FISH_COLOR="\e[38;2;40;95;160m"
FISH_BORDER="\e[38;2;100;130;170m"
FISH_HIGHLIGHT="\e[38;2;30;150;170m"
RESET="\e[0m"

# STATUS COLORS
FISH_OK="\e[38;2;0;140;95m"
FISH_ERROR="\e[38;2;180;50;50m"
FISH_WARN="\e[38;2;200;150;40m"

echo -e "${FISH_COLOR} Welcome to FISH v7${RESET}"
echo -e "${FISH_HIGHLIGHT} ----------------------------------------------------------------------------- ${RESET}"
echo

ok() { echo -e "${FISH_OK}✔ $1${RESET}"; }
err() { echo -e "${FISH_ERROR}✘ $1${RESET}"; }
warn() { echo -e "${FISH_WARN}! $1${RESET}"; }

# PROGRESS BAR
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

# COMMANDS
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

view() { ls --color=always -lah "$@"; }

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

run() {
    file="$1"
    [[ -z "$file" ]] && { err "file required"; return; }
    [[ ! -f "$file" ]] && { err "file not found"; return; }

    case "$file" in
        *.py) python3 "$file" ;;
        *.lua) lua "$file" ;;
        *.sh) bash "$file" ;;
        *) warn "unknown file type"; return ;;
    esac
}

copy() { cp "$1" "$2" && ok "copied" || err "copy failed"; }

move() { mv "$1" "$2" && ok "moved" || err "move failed"; }

connect() { ssh "$@" && ok "connected" || err "connection failed"; }

edit() { nano "$1"; }

whereami() { pwd; }

hardware() { fastfetch; }
disks() { lsblk; }
mdisks() { sudo fdisk -l; }

ver() { echo "FISH v7 (2025)"; }

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
    echo "FISH v7 Commands:"
    echo "  print <msg>"
    echo "  makefile <name>"
    echo "  makefolder <dir>"
    echo "  goto <dir>"
    echo "  goback <n>"
    echo "  delete <file>"
    echo "  view"
    echo "  math <expr>"
    echo "  install <pkg>"
    echo "  get <url>"
    echo "  run <file>"
    echo "  edit <file>"
    echo "  open <file>"
    echo "  connect <user@host>"
    echo "  hardware"
    echo "  disks"
    echo "  mdisks"
    echo "  ver"
    echo "  whereami"
    echo "  close/exit"
}

close() { exit 0; }

# fishShell
while true; do
    echo -ne "${FISH_COLOR}⟦FISH⟧» ${RESET}"

    read -r -a parts
    cmd="${parts[0]}"
    args=("${parts[@]:1}")

    case "$cmd" in
        help) help ;;
        print) print "${args[@]}" ;;
        makefile) makefile "${args[@]}" ;;
        makefolder) makefolder "${args[@]}" ;;
        goto) goto "${args[@]}" ;;
        goback) goback "${args[@]}" ;;
        delete) delete "${args[@]}" ;;
        view) view "${args[@]}" ;;
        wait) wait "${args[@]}" ;;
        math) math "${args[@]}" ;;
        get) get "${args[@]}" ;;
        install) install "${args[@]}" ;;
        run) run "${args[@]}" ;;
        copy) copy "${args[@]}" ;;
        move) move "${args[@]}" ;;
        connect) connect "${args[@]}" ;;
        update) update ;;
        hardware) hardware ;;
        disks) disks ;;
        mdisks) mdisks ;;
        ver) ver ;;
        edit) edit "${args[@]}" ;;
        open) open "${args[@]}" ;;
        whereami) whereami ;;
        close|exit) close ;;
        "") ;;
        *)
            if command -v "$cmd" >/dev/null 2>&1; then
                "$cmd" "${args[@]}"
            else
                err "unknown command: $cmd"
            fi
            ;;
    esac
done

alias keep-awake='systemd-inhibit --what=sleep:idle --why="Stay awake for another process" sleep infinity'

# Ensure permissions are correct to avoid 'permission denied' error (use chmod)
alias 3.10='source $HOME/.venv/3.10/bin/activate'
alias 3.12='source $HOME/.venv/3.12/bin/activate'
alias gitgraph='git log --graph --decorate --oneline --all'
alias toclip='xclip -selection clipboard'  # pipe stuff into this command, then Ctrl+V
alias mytree='tree -F --dirsfirst --gitignore'
alias rm='echo "rm has been disabled.  Use `gio trash [FILE]` or \rm instead."; false' # OR trash-put https://github.com/andreafrancia/trash-cli
alias sbrc='source ~/.bashrc && echo "ran source ~/.bashrc"'
alias chrome='google-chrome'
alias chezmoi='$HOME/bin/chezmoi'
alias qc='cd ~/projects/claude-lab && claude'
alias naut='(nautilus . &> /dev/null & disown)'
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"'
alias fromclip='xclip -o -sel c'
alias ctf="clip-to-file.py"
alias yt-dlp-all='yt-dlp -- $(fromclip | rg -o "http.+\w")'  # usage: copy text to clipboard then run command
alias html-to-md="fromclip | pandoc -f html -t markdown | toclip"
alias md-to-html="fromclip | pandoc -f markdown -t html | toclip"
# Markdown link list -> TSV for pasting into Google Sheets (Title<TAB>URL per row)
alias links-to-sheets='fromclip | perl -lne '\''if (/^\s*-\s*\[(.+?)\]\((.+)\)\s*$/) { print "$1\t$2" } else { s/^\s*-\s*//; s/^\s+|\s+$//g; print if length }'\'' | toclip'

# Machine-local, personal, or otherwise not-for-publication aliases live in
# ~/.bashrc.local, which is not managed by chezmoi and not in any repo.
# See dot_bashrc.tmpl for where it gets sourced.

# "Find command"
# Grep your PATH for runnable commands
fdc() {
    compgen -c | grep -i -- "$1" | sort -u
}

# Quickly create an excalidraw napkin sketch
# Set OBSIDIAN_VAULT in ~/.bashrc.local to point at your own vault.
draw() {
    local base="${OBSIDIAN_VAULT:-$HOME/Documents/obsidian/vault}"
    local template="$HOME/.template/blank.excalidraw.svg"
    local file="$base/01_Intake/excalidraw/$(date +%Y-%m-%d).excalidraw.svg"
    if [ ! -f "$file" ]; then
        cp "$template" "$file" && echo "File created: $file"
    else
        echo "File already exists: $file"
    fi
    echo "Opening in VSCode..."
    code "$base" "$file"
}

snapshot() {
    sudo timeshift --create --comments "pre-update" --tags D || return 1
}

update() {
    sudo apt update && sudo apt full-upgrade -y
    flatpak update -y
    sudo snap refresh
    yt-dlp -U
}


# https://www.tartley.com/posts/til-git-push-force-with-lease/
# Shadow git to warn against the use of 'git push -f'
git() {
    is_push=false
    is_force=false
    for arg in "$@"; do
        [ "$arg" = "push" ] && is_push=true
        [ "$arg" = "-f" -o "$arg" = "--force" ] && is_force=true
    done
    if [ "$is_push" = true ] && [ "$is_force" = true ]; then
        # Suggest alternative commands.
        echo "git push -f: Consider 'git push --force-with-lease --force-if-includes' instead, which is aliased to 'gpf'"
        return 1
    fi
    # Run the given command, using the git executable instead of this function.
    $(which git) "$@"
}

# git push force: using the new, safer alternatives to --force
gpf() {
    # Older versions of git don't have --force-if-includes. Fallback to omitting it.
    if ! git push --force-with-lease --force-if-includes "$@" 2>/dev/null ; then
      git push --force-with-lease "$@"
    fi
}

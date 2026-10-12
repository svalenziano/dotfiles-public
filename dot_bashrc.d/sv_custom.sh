# Launch ssh-agent at login
# script is from: git / GitHub
# https://docs.github.com/en/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases
env=~/.ssh/agent.env
agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }
agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }
agent_load_env
# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)
if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi
unset env

# CHANGES RECOMMENDED BY SHOTTS (LINUX COMMAND LINE BOOK)
# Change umask to make directory sharing easier
umask 0002

function mkcd
{
    dir=$1;
    mkdir -p "$dir" && cd "$dir";
}

# Ensure `pip` is only run in a VENV
# https://stackoverflow.com/questions/27410821/how-to-prevent-pip-install-without-virtualenv
export PIP_REQUIRE_VIRTUALENV=true

# Created by `pipx` on 2024-09-11 14:30:27
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.local/bin/sv-scripts"


# COMMENTING OUT IN FAVOR OF MISE
# FNM_PATH="$HOME/.local/share/fnm"
# if [ -d "$FNM_PATH" ]; then
#   export PATH="$FNM_PATH:$PATH"
#   eval "`fnm env`"
# fi


PATH=$PATH:$HOME/bin:/snap/bin  # Paths are colon-delimited


export EDITOR='code -w' # Set default editor to VSCode
export VISUAL='code -w' # Set default editor to VSCode



# Avoid this alias for now, to avoid accidentally pushing sensitive files
# alias chezmoi-push='chezmoi re-add -v && cd ~/.local/share/chezmoi && git add -A && git commit -m "update dotfiles" &&
#   git push'

# PDM
alias venv='eval $(pdm venv activate)'
alias penv='eval $(poetry venv activate)'

alias sv_update="~/bin/sv_update.sh"
PDM_VENV_PROMPT='{python_version}'

# todo: learn `mise` and stop using `nvm`
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion



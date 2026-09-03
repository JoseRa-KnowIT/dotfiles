# ~/.bashrc
if [[ -r ~/.bashrc_local ]]; then
    . ~/.bashrc_local
else
    . ~/dotfiles/default/.bashrc
fi

# Aliases and functions
[[ -r ~/.bash_aliases ]] && . ~/.bash_aliases

# Readline configuration and keybindings
#[[ -f ~/.inputrc ]] && . ~/.inputrc
bind '"\e\e": "\C-a\C-k"'

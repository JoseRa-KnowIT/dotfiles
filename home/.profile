# ~/.profile

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/dotfiles/scripts" ] ; then
    PATH="$HOME/dotfiles/scripts:$PATH"
fi
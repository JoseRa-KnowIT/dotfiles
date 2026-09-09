find ~/dotfiles/home/ -type f -name ".*" -exec sh -c '
    for src do
        dst="$HOME/$(basename "$src")"

        if [ -L "$dst" ]; then
            ln -srf "$src" "$dst"
        else
            ln -srb "$src" "$dst"
        fi
    done
' sh {} +

find ~/dotfiles/.config/ -type f -exec sh -c '
    for src do
        relative_path="${src#"$HOME/dotfiles/"}"
        dst="$HOME/$relative_path"
        mkdir -p "$(dirname "$dst")"

        if [ -L "$dst" ]; then
            ln -srf "$src" "$dst"
        else
            ln -srb "$src" "$dst"
        fi
    done
' sh {} +

#TODO: Configurar git en WSL
# credential.helper=/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe
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

#TODO: Configurar git en WSL
# credential.helper=/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe
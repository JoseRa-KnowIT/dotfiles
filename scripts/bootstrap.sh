find ~/dotfiles/ -type f -name ".*" -exec ln -s -f {} ~ ';'

#TODO: Configurar git en WSL
# credential.helper=/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe
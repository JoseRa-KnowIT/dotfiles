$ErrorActionPreference = 'Stop'

$file = $PROFILE.CurrentUserAllHosts
$content = '. $HOME/dotfiles/pwsh/profile.base.ps1'

if(Test-Path $file) {
    Write-Warning "Profile file '$file' already exists"
    Write-Warning "Please add the following line to the current profile if needed: $content"
}
else {
    Set-Content $file -Value $content
    "Profile file created succesfully '$file'"
}

#TODO: Instalar modulos requeridos
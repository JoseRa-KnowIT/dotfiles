$ErrorActionPreference = 'Stop'

$file = $PROFILE.CurrentUserAllHosts
$content = '. $HOME/dotfiles/pwsh/profile.base.ps1'

if(Test-Path $file) {
    Write-Warning "Profile '$file' already exists!"
    Write-Warning "Please add the following line to the current profile if needed: $content"
}
else {
    $null = New-Item $file -ItemType File -Force
    Set-Content $file -Value $content -Force
    Write-Host "Profile file created succesfully '$file'`n" -Foreground Blue
}

Import-Module Microsoft.PowerShell.PSResourceGet
Set-PSResourceRepository PSGallery -Trusted
Install-PSResource -RequiredResourceFile $PSScriptRoot/RequiredModules.psd1
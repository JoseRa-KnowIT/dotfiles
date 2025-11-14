if($PSEdition -eq 'Desktop') { $Global:IsWindows = $true }
if(!$env:Docs) {
    $env:Docs = $IsWindows ? [Environment]::GetFolderPath('MyDocuments') : "$HOME/Docs"
}
$Global:IsWindowsTerminal = [bool]($env:WT_SESSION)

New-PSDrive -Root $HOME\repos -Name 'GIT' -PSProvider FileSystem | Out-Null
# New-PSDrive -Root $HOME\DRIVE -Name 'OneDrive' -PSProvider FileSystem | Out-Null

$PSDefaultParameterValues['Install-Module:Repository'] = 'PSGallery'
$PSDefaultParameterValues['Invoke-Pester:Output'] = 'Detailed'

#region === PSReadLine ===

if($IsCoreCLR) {
    $PSStyle.Formatting.Verbose = $PSStyle.Foreground.Cyan
    $PSStyle.Formatting.Debug = $PSStyle.Foreground.Yellow
    $PSStyle.Formatting.TableHeader = $PSStyle.Foreground.Blue + $PSStyle.Bold
    $PSStyle.Formatting.FormatAccent = $PSStyle.Foreground.Blue + $PSStyle.Bold
    $PSStyle.FileInfo.Directory = $PSStyle.Foreground.BrightMagenta
}

$PSReadLineOptions = @{
    EditMode         = 'Windows'
    PredictionSource = 'History'
    Colors = @{
        Type             = 'DarkYellow'
        Keyword          = 'Magenta'
        Operator         = 'Blue'
        Parameter        = 'Blue'
        InlinePrediction = if($IsWindowsTerminal) { 'DarkCyan' } else { 'DarkGray' }
    }
    HistorySearchCursorMovesToEnd = $true
}
Set-PSReadLineOption @PSReadLineOptions

Set-PSReadLineKeyHandler -Key 'Alt+j','DownArrow' -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key 'Alt+k','UpArrow' -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key 'Alt+h' -Function BackwardDeleteChar
Set-PSReadLineKeyHandler -Key 'Tab' -Function MenuComplete
Set-PSReadLineKeyHandler -Key 'Shift+Tab' -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Key 'Alt+l' -Function AcceptNextSuggestionWord
Set-PSReadLineKeyHandler -Key 'Alt+.' -Function Complete
Set-PSReadLineKeyHandler -Key 'Alt+f','Ctrl+LeftArrow' -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Key 'Alt+g','Ctrl+RightArrow' -Function ShellForwardWord
Set-PSReadLineKeyHandler -Key 'Alt+D' -Function KillLine
Set-PSReadLineKeyHandler -Key 'Alt+c' -Function ClearScreen

# Set-PSReadLineKeyHandler -Key 'Tab' -ScriptBlock {
#     param($key, $arg)

#      # Get the current buffer state before attempting to accept
#     $line = $null
#     $cursor = $null
#     [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

#     # Always try to accept suggestion first
#     [Microsoft.PowerShell.PSConsoleReadLine]::AcceptNextSuggestionWord($key, $arg)

#     # Check if the buffer changed (suggestion was accepted)
#     $newLine = $null
#     $newCursor = $null
#     [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$newLine, [ref]$newCursor)

#     # If nothing changed, no suggestion was present, so do tab completion
#     if ($line -eq $newLine -and $cursor -eq $newCursor) {
#         [Microsoft.PowerShell.PSConsoleReadLine]::Complete($key, $arg)
#     }
# }
# `ForwardChar` accepts the entire suggestion text when the cursor is at the end of the line.
# This custom binding makes `RightArrow` behave similarly - accepting the next word instead of the entire suggestion text.
# Set-PSReadLineKeyHandler -Key Tab `
#                          -BriefDescription ForwardCharAndAcceptNextSuggestionWord `
#                          -LongDescription 'Move cursor one character to the right in the current editing line and accept the next word in suggestion when at the end of line' `
#                          -ScriptBlock {
#     param($key, $arg)

#     $line = $null
#     $cursor = $null
#     [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

#     if ($cursor -lt $line.Length) {
#         [Microsoft.PowerShell.PSConsoleReadLine]::ForwardChar($key, $arg)
#     } else {
#         [Microsoft.PowerShell.PSConsoleReadLine]::AcceptNextSuggestionWord($key, $arg)
#     }
# }

# Set-PSReadLineKeyHandler -Key Shift+Tab `
#                          -BriefDescription NextWordAndAcceptNextSuggestion `
#                          -LongDescription 'Move cursor to the next word in the current editing line and accept the entire suggestion when at the end of line' `
#                          -ScriptBlock {
#     param($key, $arg)

#     $line = $null
#     $cursor = $null
#     [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

#     if ($cursor -lt $line.Length) {
#         [Microsoft.PowerShell.PSConsoleReadLine]::NextWord($key, $arg)
#     } else {
#         [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion($key, $arg)
#     }
# }

#endregion

#region === Alias y funciones para mi comodidad

New-Alias gazc Get-AzContext
New-Alias ib Invoke-Build
New-Alias ip Invoke-Pester
New-Alias fm far

if($env:TERM_PROGRAM -eq 'vscode') {
    Invoke-Build.ArgumentCompleters.ps1
}

if($IsWindows) {
    function ln ($TargetPath, $LinkPath, [switch]$Symbolic, [switch]$Force)
    {
        $ErrorActionPreference = 'Stop'

        $linkType =
            if($Symbolic)
                { 'SymbolicLink' }
            elseif(Test-Path $TargetPath -PathType Container)
                { 'Junction' }
            else
                { 'HardLink' }

        if(!$Symbolic) {
            $TargetPath = (Resolve-Path $TargetPath).Path
        }
        New-Item -ItemType $linkType -Path $LinkPath -Value $TargetPath -Force:$Force
    }
}

function nd ($FolderName)
{
    New-Item -ItemType Directory $FolderName
    Set-Location $FolderName
}

function far
{
    & 'C:\Program Files\Far Manager\Far.exe' .
}

function Get-CmdletAlias ($CmdletName)
{
    Get-Alias | Where-Object { $_.Definition -like "*$CmdletName*" } |
    Format-Table Definition, Name -AutoSize
}

#endregion

#region === Argument Completers ===

# WinGet parameter completion
if($IsWindows) {
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)

    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# GitHub CLI
if(Get-Command gh -ErrorAction Ignore) {
    Invoke-Expression -Command $(gh completion -s powershell | Out-String)
}

# Azure CLI
Register-ArgumentCompleter -Native -CommandName az -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    $completion_file = New-TemporaryFile
    $env:ARGCOMPLETE_USE_TEMPFILES = 1
    $env:_ARGCOMPLETE_STDOUT_FILENAME = $completion_file
    $env:COMP_LINE = $wordToComplete
    $env:COMP_POINT = $cursorPosition
    $env:_ARGCOMPLETE = 1
    $env:_ARGCOMPLETE_SUPPRESS_SPACE = 0
    $env:_ARGCOMPLETE_IFS = "`n"
    $env:_ARGCOMPLETE_SHELL = 'powershell'
    az 2>&1 | Out-Null
    Get-Content $completion_file | Sort-Object | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
    Remove-Item $completion_file, Env:\_ARGCOMPLETE_STDOUT_FILENAME, Env:\ARGCOMPLETE_USE_TEMPFILES, Env:\COMP_LINE, Env:\COMP_POINT, Env:\_ARGCOMPLETE, Env:\_ARGCOMPLETE_SUPPRESS_SPACE, Env:\_ARGCOMPLETE_IFS, Env:\_ARGCOMPLETE_SHELL
}

# AWS CLI
# PowerShell parameter completion shim for the aws CLI
<# Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        $env:COMP_LINE = $wordToComplete
        $env:COMP_POINT = $cursorPosition
        foreach($result in aws_completer) {
            [System.Management.Automation.CompletionResult]::new($result, $result, 'ParameterValue', $result)
        }
} #>

#endregion



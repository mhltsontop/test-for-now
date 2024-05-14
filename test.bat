@echo off
:: Vérification si le script est exécuté en tant qu'administrateur
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Ce script nécessite des privilèges d'administrateur. Redémarrage avec élévation de privilèges...
    powershell.exe -Command "Start-Process -Verb RunAs '%0' -ArgumentList '%*' && exit"
    goto :eof
)

:: Vos commandes ici
mkdir "%localappdata%\Spotify\Update"
del "%localappdata%\Spotify\Update"
icacls "%localappdata%\Spotify\Update" /deny "%username%":D
icacls "%localappdata%\Spotify\Update" /deny "%username%":R

pause >nul
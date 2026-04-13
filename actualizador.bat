@echo off
setlocal enabledelayedexpansion

:: 1. Entrar en la carpeta del script (soporta rutas de red UNC)
pushd "%~dp0"

:: --- CONFIGURACION ---
set "EXE_NAME=GS1-BARTENDER.exe"
set "URL_VERSION=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/version.txt"
set "URL_EXE=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/GS1-BARTENDER.exe"

title Buscador de Actualizaciones GS1

echo Comprobando version en GitHub...
curl -s -L %URL_VERSION% -o version_remota.txt

:: Si no existe version.txt local, creamos uno base
if not exist version.txt echo 0.0.0 > version.txt

set /p LOCAL_V=<version.txt
set /p REMOTE_V=<version_remota.txt

:: Limpiar espacios
set LOCAL_V=%LOCAL_V: =%
set REMOTE_V=%REMOTE_V: =%

echo Version Local: [%LOCAL_V%]
echo Version GitHub: [%REMOTE_V%]

if "%LOCAL_V%"=="%REMOTE_V%" (
    echo Programa actualizado.
    del version_remota.txt
    timeout /t 1 > nul
    :: Si ya esta actualizado, abrimos el programa y salimos
    start "" "%EXE_NAME%" /noupdate
    popd
    exit
)

echo.
echo ! NUEVA VERSION DETECTADA !
echo.

:: Matamos el proceso para asegurar que el archivo no este bloqueado
taskkill /f /im "%EXE_NAME%" > nul 2>&1
timeout /t 1 /nobreak > nul

echo Abriendo asistente de descarga...
:: Descarga con barra grafica grafica de Windows (PowerShell)
powershell -Command "$url='%URL_EXE%'; $dest='%EXE_NAME%.new'; Write-Progress -Activity 'Actualizando GS1 BarTender' -Status 'Descargando nuevo ejecutable...' -PercentComplete 0; (New-Object System.Net.WebClient).DownloadFile($url, $dest); Write-Progress -Activity 'Actualizando GS1 BarTender' -Status 'Completado' -PercentComplete 100;"

:: Verificacion de seguridad (evitar archivos corruptos)
if not exist "%EXE_NAME%.new" (
    echo [ERROR] No se pudo descargar el archivo.
    pause
    popd
    exit
)

for %%I in ("%EXE_NAME%.new") do set FILESIZE=%%~zI
if !FILESIZE! LSS 1000 (
    echo [ERROR] Archivo corrupto o no encontrado en GitHub.
    del "%EXE_NAME%.new"
    pause
    popd
    exit
)

echo Instalando archivos...
:: Primero actualizamos el txt de version
curl -s -L %URL_VERSION% -o version.txt
:: Sustituimos el EXE
move /y "%EXE_NAME%.new" "%EXE_NAME%"

:: Quitar bloqueo de seguridad de Windows al archivo nuevo
powershell -Command "Unblock-File -Path '%EXE_NAME%'"

echo.
echo ==================================================
echo   ACTUALIZACION COMPLETADA
echo   Por favor, abre el programa manualmente ahora.
echo ==================================================
echo.

del version_remota.txt
timeout /t 3
popd
exit
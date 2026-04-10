@echo off
setlocal enabledelayedexpansion

:: 1. Soporte para rutas de red (UNC)
pushd "%~dp0"

:: CONFIGURACION
set "EXE_NAME=GS1_BARTENDER.exe"
set "URL_VERSION=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/version.txt"
set "URL_EXE=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/GS1_BARTENDER.exe"

title Buscando actualizaciones...

:: 2. Descargar version remota
curl -s -L %URL_VERSION% -o version_remota.txt

:: 3. Verificar si existe version.txt local, si no, crear uno basico
if not exist version.txt echo 0.0.0 > version.txt

:: 4. Leer versiones
set /p LOCAL_V=<version.txt
set /p REMOTE_V=<version_remota.txt

:: Limpiar posibles espacios
set LOCAL_V=%LOCAL_V: =%
set REMOTE_V=%REMOTE_V: =%

echo Version Local: [%LOCAL_V%]
echo Version Remota: [%REMOTE_V%]

:: 5. Comparar versiones
if "%LOCAL_V%"=="%REMOTE_V%" (
    echo El programa ya esta actualizado.
    del version_remota.txt
    start "" "%EXE_NAME%" /noupdate
    popd
    exit
)

:: 6. Actualizar si son distintas
echo Nueva version detectada. Actualizando...
timeout /t 2 /nobreak > nul

:: Matar el proceso si sigue abierto
taskkill /f /im "%EXE_NAME%" > nul 2>&1

echo Descargando GS1_BARTENDER.exe...
curl -L %URL_EXE% -o "%EXE_NAME%.new"
echo Descargando version.txt...
curl -s -L %URL_VERSION% -o version.txt

echo Instalando...
move /y "%EXE_NAME%.new" "%EXE_NAME%"

echo Hecho. Reiniciando...
del version_remota.txt
start "" "%EXE_NAME%" /noupdate

:: 7. Liberar ruta de red y salir
popd
exit
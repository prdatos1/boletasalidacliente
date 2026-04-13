@echo off
setlocal enabledelayedexpansion

:: 1. Entrar en la carpeta del script (Soporte UNC para red)
pushd "%~dp0"

:: --- CONFIGURACION ---
set "EXE_NAME=GS1-BARTENDER.exe"
set "URL_VERSION=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/version.txt"
set "URL_EXE=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/GS1-BARTENDER.exe"

title Buscador de Actualizaciones GS1

echo Comprobando version en GitHub...
curl -s -L %URL_VERSION% -o version_remota.txt

if not exist version.txt echo 0.0.0 > version.txt
set /p LOCAL_V=<version.txt
set /p REMOTE_V=<version_remota.txt

set LOCAL_V=%LOCAL_V: =%
set REMOTE_V=%REMOTE_V: =%

echo Version Local: [%LOCAL_V%]
echo Version GitHub: [%REMOTE_V%]

if "%LOCAL_V%"=="%REMOTE_V%" (
    echo Programa actualizado.
    del version_remota.txt
    timeout /t 1 > nul
    start "" "%EXE_NAME%" /noupdate
    popd
    exit
)

echo.
echo ! NUEVA VERSION DETECTADA !
echo.

:: Matar el proceso y esperar un segundo extra
taskkill /f /im "%EXE_NAME%" > nul 2>&1
timeout /t 2 /nobreak > nul

echo Descargando nueva version...
powershell -Command "$url='%URL_EXE%'; $dest='%EXE_NAME%.new'; (New-Object System.Net.WebClient).DownloadFile($url, $dest);"

:: Verificacion de descarga exitosa
if not exist "%EXE_NAME%.new" (
    echo [ERROR] No se pudo descargar el archivo de GitHub.
    pause
    popd
    exit
)

:: --- BUCLE DE REEMPLAZO SEGURO ---
echo Intentando sustituir el archivo...

:intentar_borrar
del /f /q "%EXE_NAME%" > nul 2>&1
if exist "%EXE_NAME%" (
    echo El archivo todavia esta en uso. Reintentando en 1 segundo...
    timeout /t 1 /nobreak > nul
    goto intentar_borrar
)

copy /y "%EXE_NAME%.new" "%EXE_NAME%" > nul
if errorlevel 1 (
    echo [ERROR] No se pudo copiar el nuevo archivo. Comprueba los permisos de la carpeta.
    pause
    popd
    exit
)

:: Actualizar version.txt local
curl -s -L %URL_VERSION% -o version.txt

:: Limpieza y desbloqueo
del "%EXE_NAME%.new"
del version_remota.txt
powershell -Command "Unblock-File -Path '%EXE_NAME%'"

echo.
echo ==================================================
echo   ACTUALIZACION COMPLETADA CON EXITO
echo   Version instalada: v%REMOTE_V%
echo ==================================================
echo.
timeout /t 3
popd
exit
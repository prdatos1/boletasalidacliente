@echo off
setlocal enabledelayedexpansion

:: 1. Soporte para rutas de red
pushd "%~dp0"

:: --- CONFIGURACION ---
set "EXE_NAME=GS1-BARTENDER.exe"
set "URL_VERSION=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/version.txt"
set "URL_EXE=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/GS1-BARTENDER.exe"

title Buscador de Actualizaciones GS1

echo Comprobando version en GitHub...
curl -s -L %URL_VERSION% -o version_github.txt

:: Si no hay version.txt local, creamos uno
if not exist version.txt echo 0.0.0 > version.txt

set /p LOCAL_V=<version.txt
set /p REMOTE_V=<version_github.txt

:: Limpiar espacios y basura
set LOCAL_V=%LOCAL_V: =%
set REMOTE_V=%REMOTE_V: =%

echo Local:  [%LOCAL_V%]
echo GitHub: [%REMOTE_V%]

:: Si son iguales, entramos al programa y salimos
if "%LOCAL_V%"=="%REMOTE_V%" (
    echo Programa al dia.
    del version_github.txt
    start "" "%EXE_NAME%" /noupdate
    popd
    exit
)

echo.
echo ========================================
echo   NUEVA VERSION DETECTADA: v%REMOTE_V%
echo ========================================
echo.

:: 2. Matar el proceso agresivamente
taskkill /f /im "%EXE_NAME%" > nul 2>&1
timeout /t 2 /nobreak > nul

:: 3. Descarga con barra de progreso (Todo en una linea para evitar errores)
echo Bajando nueva version...
powershell -Command "$url='%URL_EXE%'; $dest='%EXE_NAME%.new'; Write-Progress -Activity 'Actualizando GS1' -Status 'Descargando...' -PercentComplete 50; (New-Object System.Net.WebClient).DownloadFile($url, $dest); Write-Progress -Activity 'Actualizando GS1' -Status 'Completado' -PercentComplete 100;"

if not exist "%EXE_NAME%.new" (
    echo [ERROR] No se pudo descargar el archivo.
    pause
    popd
    exit
)

:: 4. BUCLE AGRESIVO DE REEMPLAZO
echo Intentando eliminar version antigua...
:retry_del
del /f /q "%EXE_NAME%" > nul 2>&1
if exist "%EXE_NAME%" (
    echo El archivo sigue bloqueado por el sistema. Reintentando...
    timeout /t 1 > nul
    goto retry_del
)

echo Instalando...
move /y "%EXE_NAME%.new" "%EXE_NAME%" > nul
copy /y version_github.txt version.txt > nul

:: 5. Desbloqueo de seguridad
powershell -Command "Unblock-File -Path '%EXE_NAME%'"

echo.
echo ACTUALIZACION COMPLETADA.
echo El programa se ha cerrado. Abrelo manualmente.
echo.

del version_github.txt
timeout /t 5
popd
exit
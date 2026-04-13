@echo off
setlocal enabledelayedexpansion

:: 1. Soporte para rutas de red UNC
pushd "%~dp0"

:: --- CONFIGURACION ---
set "EXE_NAME=GS1-BARTENDER.exe"
set "URL_VERSION=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/version.txt"
set "URL_EXE=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/GS1-BARTENDER.exe"

title Actualizador GS1 - Verificacion Forzada

:: 2. Descargar version remota a un archivo temporal
curl -s -L %URL_VERSION% -o version_remota.tmp

if not exist version.txt echo 0.0.0 > version.txt
set /p LOCAL_V=<version.txt
set /p REMOTE_V=<version_remota.tmp

set LOCAL_V=%LOCAL_V: =%
set REMOTE_V=%REMOTE_V: =%

if "%LOCAL_V%"=="%REMOTE_V%" (
    echo Programa actualizado.
    del version_remota.tmp > nul 2>&1
    start "" "%EXE_NAME%" /noupdate
    popd
    exit
)

echo.
echo ! NUEVA VERSION DETECTADA: v%REMOTE_V% !
echo.

:: 3. Cerrar el proceso
taskkill /f /im "%EXE_NAME%" > nul 2>&1
timeout /t 2 /nobreak > nul

:: 4. Descargar el nuevo EXE con un nombre temporal
echo Descargando nueva version...
if exist "NUEVO_GS1.tmp" del /f /q "NUEVO_GS1.tmp"

:: Descarga con barra grafica
powershell -Command "$url='%URL_EXE%'; $dest='NUEVO_GS1.tmp'; (New-Object System.Net.WebClient).DownloadFile($url, $dest);"

:: 5. VERIFICACION DE DESCARGA
if not exist "NUEVO_GS1.tmp" (
    echo [ERROR] No se pudo descargar el archivo. No se tocara nada.
    del version_remota.tmp > nul 2>&1
    pause
    popd
    exit
)

:: 6. SUSTITUCION CON REDUNDANCIA
echo Aplicando cambios...

:: A: Quitamos el EXE viejo (lo renombramos para asegurar que no esta bloqueado)
if exist "%EXE_NAME%.bak" del /f /q "%EXE_NAME%.bak"
ren "%EXE_NAME%" "%EXE_NAME%.bak" > nul 2>&1

if exist "%EXE_NAME%" (
    echo [ERROR] El archivo viejo sigue bloqueado. Reintentando...
    timeout /t 2 > nul
    ren "%EXE_NAME%" "%EXE_NAME%.bak" > nul 2>&1
)

:: B: Ponemos el nuevo
ren "NUEVO_GS1.tmp" "%EXE_NAME%"

:: 7. COMPROBACION FINAL DE EXITO
if exist "%EXE_NAME%" (
    if not exist "NUEVO_GS1.tmp" (
        :: SI EL NUEVO EXISTE Y EL TMP HA DESAPARECIDO (renombrado exito)
        echo [+] El EXE se ha sustituido con exito.
        
        :: AHORA Y SOLO AHORA ACTUALIZAMOS EL TXT
        copy /y version_remota.tmp version.txt > nul
        echo [+] Fichero version.txt actualizado a v%REMOTE_V%.
        
        :: Desbloqueamos el archivo
        powershell -Command "Unblock-File -Path '%EXE_NAME%'"
        
        :: Borramos el backup viejo
        del /f /q "%EXE_NAME%.bak" > nul 2>&1
    )
) else (
    echo.
    echo [ERROR CRITICO] No se ha podido sustituir el EXE. 
    echo Manteniendo version.txt antigua para reintentar en el proximo arranque.
    :: Si falló el renombrado del nuevo, intentamos restaurar el viejo si existe
    if exist "%EXE_NAME%.bak" ren "%EXE_NAME%.bak" "%EXE_NAME%"
    pause
)

:: Limpieza
del version_remota.tmp > nul 2>&1
echo.
echo Proceso finalizado.
timeout /t 5
popd
exit
@echo off
setlocal enabledelayedexpansion

:: 1. Entrar en la carpeta del script (Soporte para rutas de red UNC)
pushd "%~dp0"

:: --- CONFIGURACION ---
set "EXE_NAME=GS1-BARTENDER.exe"
set "URL_VERSION=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/version.txt"
set "URL_EXE=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/GS1-BARTENDER.exe"

title Actualizador GS1 - Verificacion de integridad

echo Comprobando version en GitHub...
:: Bajamos la version de GitHub a un temporal para comparar
curl -s -L %URL_VERSION% -o version_github.txt

if not exist version.txt echo 0.0.0 > version.txt
set /p LOCAL_V=<version.txt
set /p REMOTE_V=<version_github.txt

:: Limpiar espacios y basura
set LOCAL_V=%LOCAL_V: =%
set REMOTE_V=%REMOTE_V: =%

echo Version Local:  [%LOCAL_V%]
echo Version GitHub: [%REMOTE_V%]

:: Si son iguales, salimos y abrimos el programa
if "%LOCAL_V%"=="%REMOTE_V%" (
    echo Programa actualizado.
    del version_github.txt > nul 2>&1
    start "" "%EXE_NAME%" /noupdate
    popd
    exit
)

echo.
echo ! ACTUALIZACION PENDIENTE: v%REMOTE_V% !
echo.

:: 2. Matar el proceso y asegurar que no haya bloqueos
taskkill /f /im "%EXE_NAME%" > nul 2>&1
timeout /t 2 /nobreak > nul

:: 3. Descargar a un archivo temporal intermedio
echo Descargando nueva version...
set "TEMP_DOWNLOAD=GS1_NUEVO_DESCARGA.tmp"
if exist "%TEMP_DOWNLOAD%" del /f /q "%TEMP_DOWNLOAD%"

:: Descarga con barra grafica de PowerShell
powershell -Command "$url='%URL_EXE%'; $dest='%TEMP_DOWNLOAD%'; (New-Object System.Net.WebClient).DownloadFile($url, $dest);"

if not exist "%TEMP_DOWNLOAD%" (
    echo [ERROR] La descarga ha fallado. No se modificara nada.
    del version_github.txt > nul 2>&1
    pause
    start "" "%EXE_NAME%" /noupdate
    popd
    exit
)

:: 4. REEMPLAZO FORZADO
echo Intentando instalar la nueva version...

:intentar_borrar
del /f /q "%EXE_NAME%" > nul 2>&1
if exist "%EXE_NAME%" (
    echo El archivo sigue bloqueado por el sistema. Reintentando en 1 segundo...
    timeout /t 1 /nobreak > nul
    goto intentar_borrar
)

:: Movemos/Renombramos el temporal al nombre real
ren "%TEMP_DOWNLOAD%" "%EXE_NAME%"

:: 5. VERIFICACION DE EXITO ANTES DE ACTUALIZAR EL TXT
if exist "%EXE_NAME%" (
    echo.
    echo [+] Ejecutable actualizado correctamente.
    
    :: ACTUALIZAMOS EL VERSION.TXT SOLO AHORA
    echo %REMOTE_V% > version.txt
    echo [+] Fichero de version actualizado a v%REMOTE_V%.

    :: Desbloquear para que Windows no de errores al abrir
    powershell -Command "Unblock-File -Path '%EXE_NAME%'"
    
    echo.
    echo ==================================================
    echo    ACTUALIZACION COMPLETADA CON EXITO
    echo ==================================================
) else (
    echo.
    echo [ERROR CRITICO] El ejecutable no se pudo reemplazar. 
    echo La proxima vez que abras el programa se volvera a intentar.
    pause
)

:: Limpieza final
del version_github.txt > nul 2>&1
timeout /t 5
popd
exit
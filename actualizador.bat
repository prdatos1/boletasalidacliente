@echo off
setlocal enabledelayedexpansion

:: 1. Entrar en la carpeta del script (Soporte UNC para red)
pushd "%~dp0"

:: --- CONFIGURACION ---
set "EXE_NAME=GS1-BARTENDER.exe"
set "URL_VERSION=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/version.txt"
set "URL_EXE=https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/GS1-BARTENDER.exe"

title Actualizador GS1 - Forzando reemplazo

echo Verificando versiones...
curl -s -L %URL_VERSION% -o version_github.txt

if not exist version.txt echo 0.0.0 > version.txt
set /p LOCAL_V=<version.txt
set /p REMOTE_V=<version_github.txt

:: Limpiar caracteres extraños
set LOCAL_V=%LOCAL_V: =%
set REMOTE_V=%REMOTE_V: =%

echo Local:  [%LOCAL_V%]
echo GitHub: [%REMOTE_V%]

if "%LOCAL_V%"=="%REMOTE_V%" (
    echo No hay cambios.
    del version_github.txt
    start "" "%EXE_NAME%" /noupdate
    popd
    exit
)

echo.
echo === INICIANDO ACTUALIZACION ===
echo.

:: 2. Matar el proceso y esperar a que Windows lo suelte
taskkill /f /im "%EXE_NAME%" > nul 2>&1
timeout /t 2 /nobreak > nul

:: 3. Descargar el nuevo EXE con un nombre temporal
echo Descargando archivo nuevo...
curl -L %URL_EXE% -o "GS1_NUEVO.tmp"

if not exist "GS1_NUEVO.tmp" (
    echo [ERROR] No se pudo descargar el archivo de GitHub.
    pause
    start "" "%EXE_NAME%" /noupdate
    popd
    exit
)

:: 4. ELIMINAR EL ANTIGUO (Paso critico)
echo Eliminando version antigua...
:retry_del
del /f /q "%EXE_NAME%" > nul 2>&1
if exist "%EXE_NAME%" (
    echo El archivo sigue bloqueado. Reintentando...
    timeout /t 1 > nul
    goto retry_del
)

:: 5. RENOMBRAR EL NUEVO
echo Instalando nueva version...
ren "GS1_NUEVO.tmp" "%EXE_NAME%"

if not exist "%EXE_NAME%" (
    echo [ERROR] No se pudo renombrar el archivo.
    pause
    popd
    exit
)

:: 6. Actualizar version.txt local
copy /y version_github.txt version.txt > nul

:: 7. Desbloquear seguridad de Windows
powershell -Command "Unblock-File -Path '%EXE_NAME%'"

echo.
echo ========================================
echo   ACTUALIZADO A v%REMOTE_V%
echo ========================================
echo.

del version_github.txt
timeout /t 3
popd
exit
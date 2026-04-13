# Sistema de Actualización Automática - Boleta Salida Cliente

Este repositorio contiene los archivos necesarios para el sistema de actualización automática de la aplicación principal `GS1-BARTENDER.exe`. El sistema utiliza una arquitectura de **Lanzador/Actualizador** (`ActualizadorGS.exe`) separada de la aplicación principal para garantizar una actualización robusta y sin errores.

## 📋 Requisitos Previos

Para que la aplicación funcione correctamente, el ordenador debe tener instalado:
* **BarTender 2021 Professional** (o superior).
* **BarTender SDK** (incluido habitualmente en la instalación completa de BarTender). Sin el SDK, la aplicación no podrá comunicarse con el motor de impresión.

## ⚙️ Instalación y Configuración Inicial

Para instalar la aplicación por primera vez en un equipo, siga estos pasos:

1.  **Crear Carpeta:** Cree una carpeta en la ubicación que desee de su ordenador (ej: `C:\GS1-BarTender` o en una unidad de red).
2.  **Descargar Archivos:** Copie dentro de esa carpeta los archivos descargados de este repositorio de GitHub:
    * `ActualizadorGS.exe`
    * `GS1-BARTENDER.exe`
    * `version.txt`
3.  **Acceso Directo:** Haga clic derecho sobre **`ActualizadorGS.exe`** -> *Enviar a* -> *Escritorio (crear acceso directo)*.

## 🚀 Instrucciones de Ejecución para el Usuario Final

**⚠️ AVISO IMPORTANTE:**
El usuario debe iniciar el programa **SIEMPRE** a través del acceso directo del **`ActualizadorGS.exe`** que se ha creado en el escritorio.

* **¿Por qué?** Porque este archivo es el que se encarga de conectar con GitHub, verificar si hay una versión nueva y descargarla antes de abrir el programa principal.
* **Nunca** ejecute directamente el archivo `GS1-BARTENDER.exe`, ya que omitirá la comprobación de actualizaciones y podría trabajar con datos o formatos desactualizados.

## 🛠️ Proceso de Actualización (Flujo del Desarrollador)

Para publicar una nueva versión y que se distribuya automáticamente a todos los usuarios:

1.  **Compilar:** Compile el proyecto `GS1-BARTENDER` en Visual Studio para obtener el nuevo `.exe`.
2.  **Número de Versión:** Actualice su archivo `version.txt` local con el nuevo número (ej: `1.0.5`).
3.  **Subir a GitHub:** Suba tanto el nuevo **`GS1-BARTENDER.exe`** como el nuevo **`version.txt`** a la rama `main` de este repositorio.

---

## 🔍 Lógica del Sistema (`ActualizadorGS.exe`)

Cuando el usuario abre el actualizador, el programa realiza lo siguiente:

1.  **Comprobación:** Compara el número del `version.txt` local con el de este repositorio de GitHub.
2.  **Actualización:** Si en GitHub hay una versión superior:
    * Muestra una barra de progreso.
    * Descarga el nuevo ejecutable.
    * Sustituye el archivo antiguo (esto nunca falla porque el programa principal está cerrado en ese momento).
    * Actualiza el `version.txt` local.
3.  **Ejecución:** Una vez asegurada la última versión, lanza automáticamente `GS1-BARTENDER.exe` y el actualizador se cierra solo.

---
*Desarrollado para garantizar que todos los puestos de trabajo utilicen siempre la versión más reciente del sistema de etiquetado.*

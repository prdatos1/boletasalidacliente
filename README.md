# Sistema de Actualización Automática - Boleta Salida Cliente

Este repositorio contiene los archivos necesarios para el sistema de actualización automática de la aplicación principal `GS1-BARTENDER.exe`. El sistema utiliza una arquitectura de **Lanzador/Actualizador** (`ActualizadorGS.exe`) separada de la aplicación principal para garantizar una actualización robusta, segura y sin bloqueos de archivos de Windows.

## 📁 Estructura del Proyecto (Entorno Local del Cliente)

Para que el sistema funcione correctamente, el usuario final debe tener una carpeta local con los siguientes tres archivos mínimos (tal como se muestra en la imagen de referencia):

![Estructura Local](https://raw.githubusercontent.com/prdatos1/boletasalidacliente/main/version.txt?dummy=structure_img_placeholder)
*(Nota: Reemplaza esta URL con la URL real de tu imagen de estructura si la subes al repo, o simplemente usa la lista de abajo)*

* **`ActualizadorGS.exe`**: El **Lanzador y Actualizador**. Este es el punto de entrada para el usuario. Comprueba actualizaciones, las descarga e instala si es necesario, y luego abre la aplicación principal.
* **`GS1-BARTENDER.exe`**: La **Aplicación Principal**. Esta es tu aplicación de negocio que imprime las etiquetas. No debe ser ejecutada directamente por el usuario.
* **`version.txt`**: Un archivo de texto plano local que guarda el número de la versión instalada actualmente (ej: `1.0.0`).

## 🚀 Instrucciones de Ejecución para el Usuario Final

**IMPORTANTE:** Los usuarios finales **SIEMPRE** deben iniciar la aplicación haciendo doble clic en **`ActualizadorGS.exe`**.

**NO** deben ejecutar `GS1-BARTENDER.exe` directamente. Si lo hacen, no se comprobarán las actualizaciones y podrían estar trabajando con una versión obsoleta.

## 🛠️ Proceso de Actualización: Flujo de Trabajo del Desarrollador

Cada vez que hayas realizado cambios en el código de tu aplicación principal (`GS1-BARTENDER`) y quieras distribuir una nueva versión, debes seguir estos pasos exactos para que el actualizador de los clientes pueda descargarla automáticamente:

### Paso 1: Generar la Nueva Versión
1.  Realiza tus cambios en Visual Studio en el proyecto `GS1-BARTENDER`.
2.  **Compila** el proyecto en modo `Release` para generar el nuevo archivo ejecutable (.exe).
3.  Busca el archivo `GS1-BARTENDER.exe` recién compilado en tu carpeta de salida (ej: `bin/Release`).

### Paso 2: Definir el Nuevo Número de Versión
1.  Decide el nuevo número de versión (ej: si la actual es `1.0.0`, la nueva podría ser `1.0.1` o `1.1.0`).
2.  Crea o modifica un archivo `version.txt` local en tu PC y escribe **únicamente** el nuevo número de versión dentro. Ejemplo de contenido del archivo: `1.0.1`

### Paso 3: Actualizar el Repositorio de GitHub
Debes subir a la rama `main` de este repositorio (`prdatos1/boletasalidacliente`) los siguientes archivos:

1.  El nuevo archivo **`GS1-BARTENDER.exe`** que compilaste en el Paso 1.
2.  El archivo **`version.txt`** actualizado que creaste en el Paso 2.

*Es vital que subas ambos archivos. Si subes el exe pero no actualizas el version.txt en GitHub, el actualizador de los clientes no sabrá que hay una versión nueva.*

---

## 🔍 ¿Cómo funciona el Actualizador (`ActualizadorGS.exe`)?

Para tu conocimiento, este es el proceso lógico que sigue el lanzador cuando un usuario lo abre:

1.  **Lectura Local:** Lee el archivo `version.txt` local para saber qué versión tiene instalada el usuario.
2.  **Consulta a GitHub:** Descarga y lee el archivo `version.txt` de este repositorio de GitHub.
3.  **Comparación:** Compara ambos números de versión.
    * **Si son iguales:** Muestra un mensaje "Programa al día" y abre directamente `GS1-BARTENDER.exe`.
    * **Si son diferentes (GitHub es más reciente):**
        * Muestra una interfaz visual con una barra de progreso.
        * Descarga el nuevo `GS1-BARTENDER.exe` de GitHub como un archivo temporal.
        * Reemplaza el `GS1-BARTENDER.exe` local antiguo con el nuevo descargado. *Debido a que el Bartender estaba cerrado, este reemplazo nunca falla.*
        * Actualiza el archivo `version.txt` local del usuario con el nuevo número de versión.
        * Ejecuta la nueva versión de `GS1-BARTENDER.exe` y cierra el actualizador.

---
*Este sistema de actualización ha sido diseñado para solucionar problemas de archivos bloqueados por Windows y para proporcionar una experiencia de usuario limpia y profesional.*

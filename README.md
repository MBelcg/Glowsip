# GlowSip

### Blog de belleza y maquillaje

Aplicación de blog desarrollada con Flutter, FastAPI y MySQL/MariaDB.

## Sobre nuestro proyecto

GlowSip es un blog para compartir publicaciones sobre belleza, maquillaje y otros temas relacionados. Queríamos que fuera fácil de usar y que tuviera un diseño agradable, con colores rosas y vino, imágenes y opciones para consultar las publicaciones y dejar comentarios.

Para que todo funcionara, hicimos las pantallas en Flutter y las conectamos con una API en FastAPI. La API se comunica con nuestra base de datos, donde guardamos los usuarios, las publicaciones y los comentarios.

## ¿Qué se puede hacer en GlowSip?

En la aplicación se puede iniciar sesión con correo y contraseña, registrar usuarios y consultar las publicaciones del blog. Cada publicación puede tener título, descripción, imagen y etiquetas, y al abrirla se puede ver su información y sus comentarios.

También agregamos opciones para crear, editar y eliminar publicaciones, además de escribir, modificar y borrar comentarios. En la sección de perfil se puede actualizar el nombre, el correo y la contraseña. Los administradores cuentan con opciones para gestionar usuarios y publicaciones, mientras que los usuarios generales tienen las opciones que les corresponden dentro de la aplicación.

Durante el desarrollo también fuimos ajustando los colores, los botones, los menús y las pantallas para que todo mantuviera el mismo estilo.

## Herramientas que utilizamos

- **Flutter y Dart:** para crear las pantallas y la navegación.
- **FastAPI y Python:** para hacer la API que conecta la aplicación con la base de datos.
- **MySQL/MariaDB:** para guardar la información del blog.
- **SQLAlchemy:** para trabajar con la base de datos desde Python.
- **phpMyAdmin:** para revisar las tablas y los registros.
- **Git y GitHub:** para compartir los cambios y trabajar en el mismo proyecto.

## Cómo organizamos los archivos

```text
Glowsip/
├── backend_API/
├── flutter_prototipo_proyecto/
├── base_de_datos.sql
└── .gitignore
```

En `backend_API` está el código de FastAPI, y en `flutter_prototipo_proyecto` están las pantallas y demás archivos de Flutter. El archivo `base_de_datos.sql` contiene la estructura de nuestra base de datos, formada por las tablas `usuarios`, `publicaciones` y `comentarios`.

## Cómo instalar y ejecutar el proyecto

### Descargar el proyecto

Podemos obtener el proyecto de dos formas. Una es clonando el repositorio desde GitHub con estos comandos:

```bash
git clone https://github.com/MBelcg/Glowsip.git
cd Glowsip
```

La otra forma es descargarlo como archivo ZIP. Entramos al [repositorio de GlowSip](https://github.com/MBelcg/Glowsip), hacemos clic en **Code** y después en **Download ZIP**. Cuando termine la descarga, extraemos el archivo y abrimos la carpeta del proyecto en Visual Studio Code. Con cualquiera de las dos opciones podemos continuar con la configuración de la base de datos, el backend y Flutter.

### Preparar la base de datos

Para usar la base de datos, iniciamos MySQL o MariaDB y entramos a phpMyAdmin. Ahí creamos una base de datos llamada `blog_web` y, desde la opción **Importar**, seleccionamos el archivo `base_de_datos.sql`.

Ese archivo incluye las tablas, pero no los usuarios ni las publicaciones que teníamos guardados. Si se utiliza otra contraseña, usuario o puerto para MySQL, hay que revisar la conexión del backend en `backend_API/database.py`.

### Iniciar FastAPI

Necesitamos tener Python instalado. Abrimos una terminal dentro de `backend_API` y creamos un entorno virtual:

```bash
cd backend_API
python -m venv venv
```

En Windows, desde PowerShell, lo activamos así:

```powershell
.\venv\Scripts\Activate.ps1
```

Después instalamos las dependencias que utiliza el backend. Si el proyecto tiene un archivo `requirements.txt`, se pueden instalar con:

```bash
pip install -r requirements.txt
```

Cuando esté preparado, iniciamos la API con:

```bash
uvicorn main:app --reload
```

Podemos comprobar que funciona entrando a `http://127.0.0.1:8000`. Para revisar sus endpoints usamos `http://127.0.0.1:8000/docs`, donde FastAPI muestra Swagger UI.

### Iniciar Flutter

Con Flutter instalado, abrimos otra terminal desde la carpeta principal del repositorio y ejecutamos:

```bash
cd flutter_prototipo_proyecto
flutter pub get
flutter run -d chrome
```

Así se abre GlowSip en el navegador. Para que carguen las publicaciones y las demás funciones, la API debe seguir ejecutándose. Como durante el desarrollo usamos direcciones locales como `127.0.0.1`, al abrir el proyecto en otra computadora puede ser necesario ajustar la conexión con la API y la configuración CORS. También hay que revisar la ruta donde se guardan las imágenes en el backend.

## Cómo usamos la aplicación

Al abrir GlowSip podemos iniciar sesión y entrar al blog. Desde la pantalla principal vemos las publicaciones y podemos seleccionar alguna para leerla completa y revisar sus comentarios. También podemos entrar a nuestro perfil para modificar los datos de la cuenta.

Cuando iniciamos sesión como administradores, aparecen las opciones de gestión para trabajar con las publicaciones y los usuarios. El registro de nuevos usuarios también permite seleccionar el tipo de cuenta cuando se accede desde la parte de administración.

## Lo que trabajamos sobre las contraseñas

Agregamos la comprobación de correo y contraseña para iniciar sesión y guardamos las contraseñas mediante hashes en la base de datos. Para cambiar una contraseña desde el perfil, primero se pide la contraseña actual.

Como es un proyecto escolar, todavía hay partes de la API en las que faltaría reforzar la comprobación de permisos desde el servidor. Por ahora, algunas opciones se muestran u ocultan según el tipo de usuario dentro de Flutter.

## Capturas del proyecto

En esta parte podemos colocar capturas de nuestras pantallas para mostrar cómo quedó GlowSip: el inicio de sesión, la vista del blog, el detalle de las publicaciones, los comentarios, el perfil y la gestión de usuarios. También podemos incluir una captura de las tablas en phpMyAdmin y otra de Swagger UI.

## Repositorio del proyecto

El código de GlowSip y el archivo `base_de_datos.sql` se encuentran en el [repositorio de GitHub](https://github.com/MBelcg/Glowsip).

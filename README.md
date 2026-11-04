# 💚 GlucoVida
### Plataforma Digital para el Monitoreo y Control de la Diabetes

**GlucoVida** es una plataforma tecnológica desarrollada para facilitar el monitoreo, seguimiento y control de la salud de personas que viven con diabetes.

El proyecto busca proporcionar herramientas digitales que permitan a los pacientes organizar su información médica, registrar sus niveles de glucosa, administrar recordatorios y mantener una mejor comunicación con los profesionales de la salud.

La plataforma contempla una aplicación móvil y un sistema web, utilizando tecnologías modernas para ofrecer una experiencia accesible, segura e intuitiva.

---

## 🎯 Objetivo del proyecto

Desarrollar una plataforma digital multiplataforma que contribuya al seguimiento y control de la diabetes mediante herramientas de monitoreo, organización de información médica, recordatorios y comunicación entre pacientes y profesionales de la salud.

## 🚀 Funcionalidades principales

GlucoVida contempla las siguientes funcionalidades, algunas implementadas y otras en proceso de desarrollo:

- 🔐 **Autenticación de usuarios:** registro, inicio de sesión y recuperación de contraseña mediante Firebase Authentication.
- 👤 **Gestión de perfiles:** acceso personalizado de acuerdo con el rol del usuario.
- 🩸 **Control de glucosa:** registro y seguimiento de los niveles de glucosa.
- 💊 **Recordatorios:** organización de medicamentos, actividades y consultas médicas.
- 🔔 **Notificaciones:** avisos para ayudar al usuario a recordar sus actividades.
- 📅 **Gestión de citas:** solicitud y seguimiento de citas médicas.
- 🥗 **Recomendaciones saludables:** sugerencias relacionadas con alimentación y actividad física.
- 📊 **Estadísticas:** visualización y análisis de registros de salud.
- 🔒 **Protección de información:** reglas de seguridad para controlar el acceso a los datos almacenados.

## 👥 Roles del sistema

La plataforma está diseñada para trabajar con tres tipos de usuarios:

### 🧑‍⚕️ Paciente
- Acceder a su panel personal.
- Administrar sus recordatorios.
- Consultar información relacionada con su salud.
- Solicitar citas médicas.
- Visualizar recomendaciones de alimentación y ejercicio.
- Dar seguimiento a sus registros.

### 👨‍⚕️ Doctor
- Acceder a un panel especializado.
- Consultar la información autorizada de sus pacientes.
- Realizar seguimiento de pacientes vinculados.
- Gestionar las citas médicas asignadas.

### 🛡️ Administrador
- Administrar la plataforma.
- Gestionar usuarios y roles.
- Supervisar la información general del sistema.
- Controlar los permisos y el funcionamiento de los módulos administrativos.

*Las funcionalidades se encuentran en diferentes etapas de implementación.*

---

## 🛠️ Tecnologías utilizadas

| Tecnología | Descripción |
|---|---|
| Flutter | Framework para el desarrollo de aplicaciones multiplataforma. |
| Dart | Lenguaje de programación principal. |
| Firebase Authentication | Autenticación y gestión de acceso de usuarios. |
| Cloud Firestore | Base de datos NoSQL para almacenamiento de información. |
| Firebase | Servicios de backend e infraestructura. |
| Git | Control de versiones del código fuente. |
| GitHub | Repositorio y colaboración en el desarrollo. |
| Visual Studio Code | Editor utilizado para el desarrollo. |
| Android Studio | Herramienta para compilación, pruebas y emulación en Android. |

## 🏗️ Arquitectura del sistema

GlucoVida utiliza una arquitectura basada en servicios de Firebase que permite conectar la aplicación con una base de datos NoSQL en la nube.

**Flujo general:**

1. El usuario ingresa a la aplicación móvil.
2. Firebase Authentication verifica su identidad.
3. El sistema identifica su rol correspondiente.
4. La aplicación muestra el panel del paciente, doctor o administrador.
5. Cloud Firestore permite consultar y almacenar la información autorizada.
6. Las reglas de seguridad de Firestore restringen las operaciones de acuerdo con los permisos establecidos.

Esta estructura permite mantener organizada la información y facilitar futuras ampliaciones del proyecto.

---

## ⚙️ Instalación y ejecución

### Requisitos previos

Para ejecutar GlucoVida, es necesario contar con:

- Flutter SDK instalado.
- Dart SDK compatible.
- Visual Studio Code o Android Studio.
- Emulador Android o dispositivo físico.
- Configuración de Firebase correspondiente al proyecto.

### Pasos de instalación

**1. Clonar el repositorio**

```bash
git clone URL_DEL_REPOSITORIO
```

**2. Acceder al directorio del proyecto**

```bash
cd glucoVida
```

**3. Instalar las dependencias**

```bash
flutter pub get
```

**4. Verificar el entorno de Flutter**

```bash
flutter doctor
```

**5. Configurar Firebase**

Es necesario contar con un proyecto de Firebase y generar la configuración correspondiente para la aplicación.

En caso de utilizar FlutterFire CLI:

```bash
flutterfire configure
```

**6. Ejecutar la aplicación**

```bash
flutter run
```

> **Nota:** Para utilizar correctamente los servicios de autenticación y almacenamiento, se requiere configurar Firebase y las reglas de seguridad correspondientes.

---

## 🔒 Seguridad

GlucoVida incorpora mecanismos para proteger la información de los usuarios.

Entre las medidas contempladas se encuentran:

- Autenticación mediante Firebase Authentication.
- Control de acceso basado en roles.
- Reglas de seguridad en Cloud Firestore.
- Restricciones de lectura y escritura de documentos.
- Protección de información privada de pacientes.
- Validación de permisos mediante identificadores únicos de usuario (UID).

Estas medidas buscan garantizar que cada usuario pueda acceder únicamente a la información para la cual tiene autorización.

## 🌿 Control de versiones

El proyecto GlucoVida utiliza **Git y GitHub** para administrar el código fuente, mantener un historial de cambios y facilitar el desarrollo colaborativo.

### 🌳 Estructura de ramas

| Rama | Descripción |
|---|---|
| `develop` | ⭐ Rama principal del proyecto. Contiene el código central y recibe las funcionalidades integradas. |
| `develop_mello` | Rama de desarrollo individual donde se realizan modificaciones, correcciones y nuevas funcionalidades antes de integrarlas a `develop`. |
| `main` | Rama adicional del repositorio. No se utiliza como rama principal. |

### 🔄 Flujo de trabajo

1. Desarrollar nuevas funcionalidades en `develop_mello`.
2. Realizar pruebas y corregir errores.
3. Guardar y subir los cambios a GitHub.
4. Integrar los cambios aprobados a `develop`.
5. Mantener `develop` como rama principal del proyecto.

Este flujo permite organizar el desarrollo y reducir los conflictos entre versiones.

### 📥 Clonar la rama principal

```bash
git clone -b develop URL_DEL_REPOSITORIO
```

### 🚀 Subir cambios a la rama de desarrollo individual

```bash
git add .
git commit -m "Actualización de funcionalidades"
git push origin develop_mello
```

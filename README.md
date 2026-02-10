# ☕ Cafetería UIDE

Sistema integral para la gestión y consulta de servicios de la cafetería de la UIDE. Este proyecto incluye una aplicación móvil para estudiantes y personal, un panel web de administración y un backend robusto.

## 📋 Descripción

El proyecto **Cafetería UIDE** nace con el objetivo de optimizar la experiencia de usuario en la cafetería universitaria. Soluciona problemas de desconexión informativa permitiendo a los usuarios consultar el menú diario, promociones y horarios en tiempo real, además de gestionar reservas de catering y visualizar su historial de consumo.

## 🚀 Características Principales

### 📱 Aplicación Móvil (Usuarios)
- **Menú Digital:** Visualización detallada del menú del día con ingredientes y precios.
- **Promociones:** Acceso a ofertas especiales y descuentos vigentes.
- **Historial de Consumo:** Seguimiento de almuerzos para programas de fidelización (ej. almuerzo gratis).
- **Reservas:** Solicitud de servicios de catering.
- **Información General:** Horarios de atención y ubicación.
- **Autenticación:** Inicio de sesión seguro (Correo/Contraseña, Google).

### 💻 Panel Web (Administración)
- **Gestión de Menú:** Crear, editar y eliminar platillos del día.
- **Gestión de Promociones:** Administración de ofertas activas.
- **Escáner QR:** Funcionalidad para validar consumos o reservas.
- **Reportes:** Visualización de actividad y métricas básicas.

## 🛠️ Tecnologías Utilizadas

Este proyecto utiliza una arquitectura moderna dividida en tres componentes principales:

### **Backend (API REST)**
- **Runtime:** [Node.js](https://nodejs.org/)
- **Framework:** [Express.js](https://expressjs.com/)
- **Base de Datos:** MySQL (con [Sequelize](https://sequelize.org/) ORM)
- **Autenticación:** Passport.js, JWT, Firebase Admin
- **Almacenamiento:** Firebase Storage (para imágenes)

### **Móvil (Cliente)**
- **Framework:** [Flutter](https://flutter.dev/)
- **Lenguaje:** Dart
- **Gestión de Estado:** Provider
- **Servicios:** Firebase Auth, Google Sign-In, HTTP

### **Web (Administración)**
- **Librería:** [React](https://react.dev/)
- **UI Framework:** Material UI (@mui/material)
- **Iconos:** Lucide React
- **Herramientas:** HTML5 QR Code

## 📂 Estructura del Proyecto

```bash
CafeteriaUIDE/
├── docs/               # Documentación (SRS, entrevistas, etc.)
├── src/
│   ├── backend/        # Servidor Node.js y API
│   ├── movil/          # Código fuente de la App Flutter
│   └── web/            # Código fuente del Frontend React
└── README.md           # Este archivo
```

## 🔧 Instalación y Puesta en Marcha

Sigue estos pasos para ejecutar el proyecto en tu entorno local.

### Prerrequisitos
- Node.js (v18 o superior)
- Flutter SDK
- MySQL Server
- Dispositivo Android/iOS o Emulador

### 1. Configuración del Backend
```bash
cd src/backend
npm install
npm run dev
```
*Asegúrate de configurar las variables de entorno `.env` con tus credenciales de base de datos y Firebase.*

### 2. Configuración del Panel Web
```bash
cd src/web
npm install
npm start
```

### 3. Ejecución de la App Móvil
```bash
cd src/movil
flutter pub get
flutter run
```

## 👥 Autores

Este proyecto ha sido desarrollado por estudiantes de Ingeniería de Software de la UIDE:

- **Alddrin Venegas**
- **Anthony Sánchez**
- **Savier Torres**
- **Erick Morales**
- **Anderson Calva**

---
© 2026 Cafetería UIDE. Todos los derechos reservados.
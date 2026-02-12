# Program Backlog (SAFe Hierarchy)

Este documento traduce los Requerimientos Funcionales (RF) del SRS a la jerarquía de trabajo de SAFe: **Epics**, **Features** y **User Stories**.

## Epic 1: Experiencia del Estudiante (Mobile App)
**Descripción:** Proporcionar a los estudiantes una herramienta móvil intuitiva para consultar información de la cafetería y gestionar su consumo.

### Feature 1.1: Visualización de Información (Enabler de Consumo)
*Mapeo RF:* RF-01, RF-02, RF-04, RF-09
- **Story 1.1.1:** Como estudiante, quiero ver el menú del día con imágenes y precios para decidir qué almorzar. (RF-01)
- **Story 1.1.2:** Como estudiante, quiero ver las promociones destacadas en una sección separada para aprovechar ofertas. (RF-02, RF-09)
- **Story 1.1.3:** Como estudiante, quiero ver el detalle de ingredientes de un platillo para evitar alergias. (RF-01)
- **Story 1.1.4:** Como estudiante, quiero consultar el horario de atención para saber cuándo ir. (RF-04)

### Feature 1.2: Programa de Fidelización Digital
*Mapeo RF:* RF-03
- **Story 1.2.1:** Como estudiante, quiero ver un contador de mis almuerzos consumidos para saber cuánto falta para mi almuerzo gratis. (RF-03)
- **Story 1.2.2:** Como sistema, quiero registrar automáticamente un consumo al escanear un código (QR o similar) validado por caja.

### Feature 1.3: Gestión de Reservas (Catering)
*Mapeo RF:* RF-06
- **Story 1.3.1:** Como usuario, quiero acceder a un formulario para solicitar servicio de catering. (RF-06)
- **Story 1.3.2:** Como sistema, quiero validar que la solicitud sea con 48h de anticipación. (RF-06)

---

## Epic 2: Gestión Operativa y Administrativa (Web & Backend)
**Descripción:** Herramientas para que el personal de cocina y administradores gestionen el contenido y operaciones de la cafetería.

### Feature 2.1: Administración de Contenido (CMS)
*Mapeo RF:* RF-05, RF-08
- **Story 2.1.1:** Como administrador, quiero crear un nuevo platillo con foto, descripción y precio. (RF-05, RF-08)
- **Story 2.1.2:** Como administrador, quiero marcar un platillo como "Menú del Día" para que aparezca en la app.
- **Story 2.1.3:** Como administrador, quiero crear y desactivar promociones temporales. (RF-05)

### Feature 2.2: Identidad y Seguridad
*Mapeo RF:* RF-07, RF-10
- **Story 2.2.1:** Como nuevo usuario, quiero registrarme con mi correo institucional. (RF-10)
- **Story 2.2.2:** Como usuario registrado, quiero iniciar sesión con correo y contraseña. (RF-07)
- **Story 2.2.3:** Como administrador, quiero tener un rol con permisos elevados para acceder al panel web. (RNF-04)

---

## Prioridades para el Próximo PI (Program Increment)
1.  **Feature 2.2** (Identidad) - Bloqueante para el resto.
2.  **Feature 2.1** (CMS) - Necesario para llenar de datos la app.
3.  **Feature 1.1** (Visualización) - Core value para el estudiante.
